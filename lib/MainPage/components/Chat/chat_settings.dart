import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/main.dart';
import 'package:Apatite/models/chat_tile_model.dart';
import 'package:Apatite/models/user_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:Apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class ChatSettings extends StatefulWidget {
  final ChatTileModel model;
  const ChatSettings({super.key, required this.model});

  @override
  State<ChatSettings> createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
  late String _newChatName;
  File? _newPfp;
  // ignore: unused_field
  final Logger _logger = Logger("SettingsPageState");
  Uint8List? _oldPfp;

  final picker = ImagePicker();
  final cropper = ImageCropper();

  final _allParticipants = List<User>.empty(growable: true);
  final ValueNotifier<List<User>> _filteredParticipants = ValueNotifier<List<User>>([]);

  final ScrollController _scrollController = ScrollController();
  late StreamSubscription _subscription;

  String filterName = '';

  int offset = 0;
  int limit = 20;
  int lastLoad = 0;

  void _loadMoreParticipants() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (lastLoad < limit) return;
      offset += limit;
      NetworkController.websocketSend({'offset': offset, 'limit': limit, 'chat_id': widget.model.id}, WSMType.getParticipants);
    }
  }

  @override
  void initState() {
    _newChatName = widget.model.name;
    _scrollController.addListener(_loadMoreParticipants);
    _subscription = NetworkController.messageStreamController.stream.listen((message) async {
      var data = jsonDecode(message.toString());
      if (data['type'] == WSMTWrapper[WSMType.updateChat]) {
        Timer(
          Duration(seconds: 5),
          () => setState(() {
            _newPfp = null;
            _oldPfp = null;
          }),
        );
      } else if ((data['type'] == WSMTWrapper[WSMType.removeParticipant])) {
        var innerData = jsonDecode(data['data']);
        var chat = jsonDecode(innerData['chat']);
        var user = jsonDecode(innerData['user']);

        if (chat["chat_id"] == widget.model.id) return;
        setState(() {
          _allParticipants.removeWhere((element) => element.id == user["id"]);
          _filteredParticipants.value.removeWhere((element) => element.id == user["id"]);
        });
      } else if (data['type'] == WSMTWrapper[WSMType.addParticipant]) {
        var innerData = jsonDecode(data['data']);
        var u = jsonDecode(innerData['user']);

        if (u['pfp_uuid'] != null) {
          var file = await NetworkController.getFile(u['pfp_uuid']);
          var user = User.fromJson(u);
          user.pfp = file?.readAsBytesSync();
          setState(() {
            _allParticipants.add(user);
            _filteredParticipants.value.add(user);
          });
        } else {
          setState(() {
            _allParticipants.add(User.fromJson(u));
            _filteredParticipants.value.add(User.fromJson(u));
          });
        }
      } else if (data['type'] == WSMTWrapper[WSMType.getParticipants]) {
        for (var participant in data['participants']) {
          if (participant['id'] == NetworkController.me.id) {
            continue;
          } else if (participant['pfp_uuid'] != null) {
            var file = await NetworkController.getFile(participant['pfp_uuid']);
            var user = User.fromJson(participant);
            user.pfp = file?.readAsBytesSync();
            _filteredParticipants.value.add(user);
          } else {
            _filteredParticipants.value.add(User.fromJson(participant));
          }
        }
        setState(() {
          _allParticipants.addAll(_filteredParticipants.value);
        });
      }
    });

    NetworkController.websocketSend({'offset': offset, 'limit': limit, 'chat_id': widget.model.id}, WSMType.getParticipants);
    NetworkController.getFile(widget.model.pfpUUID).then((res) => {widget.model.pfp = res?.readAsBytesSync()});
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _filteredParticipants.dispose();
    super.dispose();
  }

  Widget buildImage() {
    _logger.debug("Image Stored: ${widget.model.pfpUUID} ");
    if (_newPfp != null) {
      return CircleAvatar(child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.file(_newPfp!)));
    } else if (_oldPfp != null) {
      return CircleAvatar(child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.memory(_oldPfp!)));
    } else if (_oldPfp == null && widget.model.pfpUUID != null) {
      return FutureBuilder(
        future: NetworkController.getFile(widget.model.pfpUUID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Uint8List? data = snapshot.data?.readAsBytesSync();
            _oldPfp = data;
            return CircleAvatar(child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.memory(data!)));
          } else {
            return CircularProgressIndicator();
          }
        },
      );
    } else {
      return CircleAvatar(child: Icon(Icons.person));
    }
  }

  handleUpdateSettings() async {
    if (_newChatName != widget.model.name) {
      NetworkController.changeChatName(widget.model.id, _newChatName).then((res) {
        if (res) {
          ToastService.showToast('Chat name updated');
          NetworkController.websocketSend({'chat_id': widget.model.id, 'name': _newChatName, 'user_id': NetworkController.me.id}, WSMType.updateChat);
        } else {
          ToastService.showToast('Something went wrong');
        }
      });
    }

    if (_newPfp != null) {
      Uint8List bytes = _newPfp!.readAsBytesSync();
      var newFileName = Main.getUuid() + p.extension(_newPfp!.path);
      NetworkController.uploadFile(bytes, newFileName).then(
        (res) => {
          if (res == 200)
            {
              NetworkController.changeChatPfp(widget.model.id, newFileName).then((res) {
                if (res) {
                  ToastService.showToast('PFP updated');
                  NetworkController.websocketSend({'chat_id': widget.model.id, 'pfp_uuid': newFileName, 'user_id': NetworkController.me.id}, WSMType.updateChat);
                } else {
                  ToastService.showToast('Something went wrong');
                }
              }),
            },
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.model.name), leading: IconButton(onPressed: () => Navigator.pop(context, (_) => {setState(() {})}), icon: const Icon(Icons.arrow_back))),
      backgroundColor: const Color.fromARGB(169, 68, 68, 68),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: Scaffold(
              body: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width,
                      child: GestureDetector(
                        onTap: () async {
                          final pickedFile = await picker.pickImage(source: ImageSource.gallery, preferredCameraDevice: CameraDevice.front);
                          if (pickedFile == null) {
                            return;
                          }
                          final cropped = await cropper.cropImage(
                            compressFormat: ImageCompressFormat.jpg,
                            compressQuality: 40,
                            aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                            uiSettings: [
                              AndroidUiSettings(toolbarTitle: 'Crop Image', backgroundColor: Color.fromARGB(169, 0, 0, 0), toolbarWidgetColor: Colors.black, cropStyle: CropStyle.circle, initAspectRatio: CropAspectRatioPreset.original, lockAspectRatio: false),
                            ],
                            sourcePath: pickedFile.path,
                          );
                          if (cropped == null) return;
                          _newPfp = File(cropped.path);
                          setState(() {});
                        },
                        child: buildImage(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(decoration: InputDecoration(hintText: _newChatName, border: OutlineInputBorder()), onChanged: (value) => {_newChatName = value}),
                    SizedBox(height: 10),
                    // Add participants button
                    Row(
                      children: [
                        Expanded(
                          child: FloatingActionButton(
                            heroTag: Main.getUuid(),
                            onPressed:
                                () => {
                                  Navigator.pushNamed(context, '/newChat', arguments: {'model': widget.model}),
                                },
                            child: Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(hintText: 'Search', border: OutlineInputBorder()),
                      onChanged: (value) {
                        setState(() {
                          filterName = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    ValueListenableBuilder(
                      valueListenable: _filteredParticipants,
                      builder: (context, value, child) {
                        value = value.where((element) => element.username.toLowerCase().contains(filterName.toLowerCase())).toList();
                        return Column(
                          children: List.generate(
                            value.length,
                            (i) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                value[i].pfp == null
                                    ? Hero(tag: Main.getUuid(), child: CircleAvatar(child: Icon(Icons.person)))
                                    : Hero(tag: Main.getUuid(), child: CircleAvatar(child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.memory(value[i].pfp!)))),
                                Spacer(),
                                Text(value[i].username, style: TextStyle(fontSize: 20)),
                                Spacer(),
                                FloatingActionButton(
                                  heroTag: Main.getUuid(),
                                  onPressed:
                                      () => {
                                        NetworkController.removeParticipantFromChat(widget.model.id, value[i].id).then((res) {
                                          if (res) {
                                            NetworkController.websocketSend({'chat_id': widget.model.id, 'user_id': value[i].id, 'sender_id': NetworkController.me.id}, WSMType.removeParticipant);
                                          } else {
                                            ToastService.showToast('Something went wrong');
                                          }
                                        }),
                                      },
                                  child: Icon(Icons.remove),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      () => {
                        NetworkController.removeParticipantFromChat(widget.model.id, NetworkController.me.id).then((res) {
                          if (res) {
                            NetworkController.websocketSend({'chat_id': widget.model.id, 'user_id': NetworkController.me.id, 'sender_id': NetworkController.me.id}, WSMType.removeParticipant);
                            ToastService.showToast('You left the chat');
                            Navigator.popUntil(NetworkController.mainContext!, ModalRoute.withName('/'));
                          } else {
                            ToastService.showToast('Something went wrong');
                          }
                        }),
                      },
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.redAccent[200]), iconColor: WidgetStateProperty.all(Colors.black), shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [Icon(Icons.exit_to_app), Text('Leave Chat', style: TextStyle(fontSize: 20, color: Colors.black))]),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => {handleUpdateSettings()},
                  style: ButtonStyle(shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), minimumSize: WidgetStateProperty.all(Size(60, 60))),
                  child: Icon(Icons.save, size: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
