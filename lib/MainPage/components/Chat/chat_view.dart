// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Apatite/MainPage/components/Chat/elements/message_tile.dart';
import 'package:Apatite/MainPage/components/empty_widget.dart';
import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/main.dart';
import 'package:Apatite/models/chat_tile_model.dart';
import 'package:Apatite/models/message_model.dart';
import 'package:Apatite/models/user_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:Apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:visibility_detector/visibility_detector.dart';

class ChatView extends StatefulWidget {
  final Function changePage;

  final ChatTileModel model;
  static final Logger logger = Logger("ChatView");
  const ChatView({super.key, required this.changePage, required this.model});

  @override
  State<ChatView> createState() => ChatViewState();
}

class ChatViewState extends State<ChatView> {
  final _scrollController = ScrollController();
  late ValueNotifier<List<ValueNotifier<MessageModel>>> _messagesNotifiers; // = ValueNotifier([]);
  static final List<User> _participants = [];
  String myInput = '';
  final _textController = TextEditingController();
  static List<User> get participants => _participants;
  late StreamSubscription _subscription;
  File? _file;
  late MessageModel _mineCurrent;

  int offset = 0;
  int limit = 10;
  int lastLoad = 0;

  @override
  void initState() {
    super.initState();
    _messagesNotifiers = ValueNotifier([]);
    _mineCurrent = MessageModel(sender: NetworkController.me.id, chatId: widget.model.id);
    NetworkController.getParticipants(widget.model.id).then((res) async {
      var json = jsonDecode(res);
      ChatView.logger.debug("Participants: $json");
      for (var u in json) {
        if (u['id'] == NetworkController.me.id) {
          participants.add(NetworkController.me);
        } else if (u['pfp_uuid'] != null) {
          var file = await NetworkController.getFile(u['pfp_uuid']);
          var user = User.fromJson(u);
          user.pfp = file?.readAsBytesSync();
          participants.add(user);
        } else {
          participants.add(User.fromJson(u));
        }
      }
      _subscription = NetworkController.messageStreamController.stream.listen((message) {
        var data = jsonDecode(message.toString());
        switch (WSMType.values.firstWhere((element) => element.name == data['type'], orElse: () => WSMType.def)) {
          case WSMType.loadMessages:
            {
              var list =
                  List.generate(
                    data['messages'].length,
                    (index) => MessageModel.fromJson(data['messages'][index]),
                  ).toList();

              _messagesNotifiers.value = _messagesNotifiers.value + list.map((value) => ValueNotifier(value)).toList();
              lastLoad = list.length;
              break;
            }
          case WSMType.getMessages:
            {
              var list =
                  List.generate(
                    data['messages'].length,
                    (index) => MessageModel.fromJson(data['messages'][index]),
                  ).toList();
              _messagesNotifiers.value.insertAll(0, list.map((value) => ValueNotifier(value)).toList());
              lastLoad = list.length;
              _messagesNotifiers.notifyListeners();
              break;
            }
          case WSMType.newMessage:
            {
              _messagesNotifiers.value.insert(0, ValueNotifier(MessageModel.fromJson(jsonDecode(data['data']))));
              _messagesNotifiers.notifyListeners();
              break;
            }
          case WSMType.updateMessage:
            {
              var message = MessageModel.fromJson(jsonDecode(data['data']));
              var target = _messagesNotifiers.value.firstWhere((element) => element.value.id == message.id);
              target.value = target.value.copyWith(status: message.status);
              break;
            }
          case WSMType.sendMessage:
            {
              _messagesNotifiers.value.insert(0, ValueNotifier(MessageModel.fromJson(jsonDecode(data['data']))));
              _messagesNotifiers.notifyListeners();
              break;
            }
          case WSMType.error:
            {
              ToastService.showToast(data['message']);
              break;
            }
          case WSMType.def:
          default:
            {
              break;
            }
        }
      });

      NetworkController.websocketSend({
        'offset': offset,
        'limit': limit,
        'chat_id': widget.model.id,
      }, WSMType.getMessages);
      _scrollController.addListener(_loadMoreMessages);
    });
  }

  void _loadMoreMessages() {
    if ((_scrollController.position.pixels >= (_scrollController.position.maxScrollExtent - 200)) &&
        (lastLoad == limit)) {
      offset += limit;
      NetworkController.websocketSend({
        'offset': offset,
        'limit': limit,
        'chat_id': widget.model.id,
      }, WSMType.loadMessages);
    }
  }

  String formatTimestamp() {
    var time = DateTime.now();
    return "${time.year}-${(time.month < 10) ? '0${time.month}' : time.month}-${(time.day < 10) ? '0${time.day}' : time.day} ${(time.hour < 10) ? '0${time.hour}' : time.hour}:${(time.minute < 10) ? '0${time.minute}' : time.minute}:${(time.second < 10) ? '0${time.second}' : time.second}";
  }

  Future<bool> dispatchMessage() async {
    ChatView.logger.debug("Message: ${_mineCurrent.toDynamic()}");
    if (_mineCurrent.data != null) {
      return NetworkController.uploadFile(_mineCurrent.data!, _mineCurrent.fileUuid!).then((res) {
        if (res != 200) return false;
        NetworkController.websocketSend(_mineCurrent.toDynamic(), WSMType.sendMessage);
        return true;
      });
    } else {
      NetworkController.websocketSend(_mineCurrent.toDynamic(), WSMType.sendMessage);
      return true;
    }
  }

  void sendMessage() async {
    ChatView.logger.debug("Messages: $myInput");

    if ((_mineCurrent.text == null || _mineCurrent.text!.isEmpty) && _mineCurrent.fileUuid == null) return;
    _mineCurrent.timeStamp = formatTimestamp();

    if (_mineCurrent.fileUuid == null) {
      _mineCurrent.type = MessageType.text;
    }

    _mineCurrent.status = MessageStatus.sent;

    // Send message
    await dispatchMessage();

    // messages.value = [_mineCurrent, ...messages.value];
    _mineCurrent = MessageModel(sender: NetworkController.me.id, chatId: widget.model.id);
    _textController.clear();
    clearFileSelection();
  }

  void addMyText(String text) {
    _mineCurrent.text = text;
  }

  void pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false, compressionQuality: 30);
      if (result == null) {
        return;
      }
      _file = File(result.files.single.path!);
      if (_file == null) return;
      var extension = p.extension(_file!.path);
      var type = resolveMessageType(extension);
      var fileUuid = Main.getUuid();
      _mineCurrent.fileUuid = fileUuid + extension;
      _mineCurrent.type = type;
      _mineCurrent.data = await _file!.readAsBytes();
      setState(() {});
    } catch (e) {
      ChatView.logger.err(e.toString());
    }
  }

  MessageType resolveMessageType(String extension) {
    ChatView.logger.debug("Resolving extension: $extension");
    switch (extension) {
      case ".mp4" || ".mov" || ".mkv":
        return MessageType.video;
      case ".mp3" || ".wav":
        return MessageType.audio;
      case ".png" || ".jpg" || ".jpeg":
        return MessageType.image;
      default:
        return MessageType.file;
    }
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  void clearFileSelection() {
    _mineCurrent.fileUuid = null;
    _mineCurrent.type = MessageType.text;
    setState(() {});
  }

  @override
  void dispose() {
    for (var element in _messagesNotifiers.value) {
      element.dispose();
    }
    _messagesNotifiers.dispose();
    _subscription.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.model.name),
        leading: IconButton(onPressed: () => widget.changePage(Pages.chats), icon: Icon(Icons.arrow_back)),
      ),
      backgroundColor: Color.fromARGB(169, 68, 68, 68),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ValueListenableBuilder(
                valueListenable: _messagesNotifiers,
                builder: (context, value, child) {
                  if (value.isEmpty) {
                    return WowSoEmpty();
                  }
                  // ChatView.logger.debug("Messages: ${value[value.length - 1]}");
                  return ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return ValueListenableBuilder(
                        valueListenable: value[index],
                        builder: (context, value, child) {
                          // ChatView.logger.debug("RENDERING: ${value.text}");
                          return VisibilityDetector(
                            key: Key(value.id.toString()),
                            onVisibilityChanged: (info) {
                              // ChatView.logger.debug("Visible: ${info.visibleFraction}, status: ${value.sender}");
                              if (info.visibleFraction >= 0.5 &&
                                  value.status == MessageStatus.delivered &&
                                  value.sender != NetworkController.me.id) {
                                // ChatView.logger.debug("Visible: ${value.text}");
                                value = value.copyWith(status: MessageStatus.seen);
                                NetworkController.websocketSend(value.toDynamic(), WSMType.updateMessage);
                              }
                            },
                            child: MessageTile(message: value, key: ValueKey(value.id.toString())),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(hintText: 'Type a message', border: OutlineInputBorder()),
                    onChanged: (value) => {addMyText(value)},
                  ),
                ),
                IconButton(
                  icon: _mineCurrent.fileUuid == null ? Icon(Icons.attach_file) : Icon(Icons.clear),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                    backgroundColor: WidgetStateProperty.all(Colors.cyan[900]),
                  ),
                  onPressed: () {
                    if (_mineCurrent.fileUuid == null) {
                      pickFile();
                    } else {
                      clearFileSelection();
                    }
                  },
                ),
                IconButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                    backgroundColor: WidgetStateProperty.all(Colors.cyan[900]),
                  ),
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
