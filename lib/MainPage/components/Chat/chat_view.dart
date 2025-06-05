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
  final ValueNotifier<List<MessageModel>> messages = ValueNotifier([]);
  static final List<User> _participants = [];
  String myInput = '';
  final _textController = TextEditingController();
  static List<User> get participants => _participants;

  File? _file;
  late MessageModel _mineCurrent = MessageModel(sender: NetworkController.me.id, chatId: widget.model.id);

  int offset = 0;
  int limit = 10;
  int lastLoad = 0;

  @override
  void initState() {
    super.initState();

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
      NetworkController.messageStreamController.stream.listen((message) {
        var data = jsonDecode(message.toString());
        switch (WSMType.values.firstWhere((element) => element.name == data['type'], orElse: () => WSMType.def)) {
          case WSMType.loadMessages:
            {
              var list =
                  List.generate(
                    data['messages'].length,
                    (index) => MessageModel.fromJson(data['messages'][index]),
                  ).toList();
              messages.value = messages.value + list;
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
              messages.value = messages.value + list;
              lastLoad = list.length;
              break;
            }
          case WSMType.newMessage:
            {
              messages.value = [MessageModel.fromJson(data['data']), ...messages.value];
              break;
            }
          case WSMType.updateMessage:
            {
              var message = MessageModel.fromJson(jsonDecode(data['data']));
              var tmp = messages.value;
              var index = tmp.indexWhere((element) => element.id == message.id);
              tmp[index] = message;
              messages.value = tmp;
              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
              messages.notifyListeners();
              break;
            }
          case WSMType.sendMessage:
            {
              var message = MessageModel.fromJson(jsonDecode(data['data']));
              messages.value = [message, ...messages.value];
              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
              messages.notifyListeners();
              break;
            }
          case WSMType.error:
            {
              ToastService().showToast(data['message']);
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
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);
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
    super.dispose();
    // messages.dispose();
    _textController.dispose();
    _scrollController.dispose();
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
                valueListenable: messages,
                builder: (context, value, child) {
                  if (value.isEmpty) {
                    return WowSoEmpty();
                  }
                  ChatView.logger.debug("Messages: ${value[value.length - 1]}");
                  return ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return VisibilityDetector(
                        key: Key(value[index].id.toString()),
                        onVisibilityChanged: (info) {
                          ChatView.logger.debug(
                            "Visible: ${info.visibleFraction}, status: ${value[index].status}, sender: ${value[index].sender}",
                          );
                          if (info.visibleFraction >= 0.5 &&
                              value[index].status == MessageStatus.delivered &&
                              value[index].sender != NetworkController.me.id) {
                            ChatView.logger.debug("Visible: ${value[index]}");
                            var updated = value[index];
                            updated.status = MessageStatus.seen;
                            var dynamic = updated.toDynamic();
                            NetworkController.websocketSend(dynamic, WSMType.updateMessage);
                          }
                        },
                        child: MessageTile(key: UniqueKey(), message: value[index]),
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
