import 'dart:io';
import 'dart:typed_data';

import 'package:Apatite/MainPage/components/Chat/elements/message_tile.dart';
import 'package:Apatite/MainPage/components/empty_widget.dart';
import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/main.dart';
import 'package:Apatite/models/chat_tile_model.dart';
import 'package:Apatite/models/user_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class ChatView extends StatefulWidget {
  final Function changePage;

  final ChatTileModel model;

  const ChatView({super.key, required this.changePage, required this.model});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _scrollController = ScrollController();
  final ValueNotifier<List<MessageModel>> messages = ValueNotifier([]);
  final List<User> participants = [];
  String myInput = '';
  final Logger _logger = Logger("ChatView");
  final _textController = TextEditingController();

  File? _file;
  late MessageModel _mineCurrent;

  @override
  void initState() {
    super.initState();
    // TODO: Get all participants and store them in map.

    // TODO: load 10 latest messages

    // The message is always bound to the user
    _mineCurrent = MessageModel(sender: NetworkController.me.id, chatId: widget.model.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void sendMessage() {
    _logger.debug("Messages: $myInput");

    if ((_mineCurrent.text == null || _mineCurrent.text!.isEmpty) && _mineCurrent.fileUuid == null) return;
    _mineCurrent.timeStamp = DateTime.now().toString();

    // Send message
    messages.value.add(_mineCurrent);
    _mineCurrent = MessageModel(sender: NetworkController.me.id, chatId: widget.model.id);
    _textController.clear();
    clearFileSelection();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
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
      _logger.err(e.toString());
    }
  }

  MessageType resolveMessageType(String extension) {
    _logger.info("Resolving extension: $extension");
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void clearFileSelection() {
    _mineCurrent.fileUuid = null;
    _mineCurrent.type = null;
    setState(() {});
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    messages.dispose();
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
                valueListenable: messages,
                builder: (context, value, child) {
                  if (value.isEmpty) {
                    return WowSoEmpty();
                  }
                  _logger.debug("Messages: ${value[value.length - 1]}");
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return MessageTile(message: value[index], user: NetworkController.me);
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

class MessageModel {
  int? id;
  String? text;
  String? timeStamp;
  int sender;
  int chatId;
  MessageStatus? status;
  String? fileUuid;
  Uint8List? data;

  MessageType? type;

  MessageModel({
    this.id,
    required this.sender,
    this.fileUuid,
    this.text,
    this.status,
    required this.chatId,
    this.timeStamp,
    this.type,
  });

  @override
  String toString() {
    return 'MessageModel{id: $id, sender: $sender,  message: $text, status: $status, timeStamp: $timeStamp, type: $type,  fileUuid: $fileUuid}';
  }
}
