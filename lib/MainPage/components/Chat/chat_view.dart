import 'dart:io';
import 'dart:typed_data';

import 'package:Apatite/MainPage/components/Chat/elements/message_tile.dart';
import 'package:Apatite/MainPage/components/empty_widget.dart';
import 'package:Apatite/models/chat_tile_model.dart';
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

class _ChatViewState extends State<ChatView> with ChangeNotifier {
  final _scrollController = ScrollController();
  final ValueNotifier<List<MessageModel>> messages = ValueNotifier([]);
  String myInput = '';
  final Logger _logger = Logger("ChatView");
  final _textController = TextEditingController();
  MessageModel _mineCurrent = MessageModel(isMine: true);

  @override
  void initState() {
    super.initState();
    // messages.value = List.generate(
    //   20,
    //   (index) => MessageModel(
    //     id: index,
    //     sender: index.isEven ? widget.model.id : 0,
    //     data: null,
    //     status: MessageStatus.values.elementAt(Random().nextInt(MessageStatus.values.length)),
    //     message: List.generate(Random().nextInt(150) + 1, (index) => 'x').join(),
    //     timeStamp: DateTime.now().toString(),
    //     type: MessageType.values.elementAt(Random().nextInt(MessageType.values.length)),
    //     isMine: index.isEven,
    //   ),
    // );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void sendMessage() {
    _logger.debug("Messages: ${myInput}");

    if ((_mineCurrent.message == null || _mineCurrent.message!.isEmpty) && _mineCurrent.data == null) return;
    _mineCurrent.timeStamp = DateTime.now().toString();

    // Send message

    messages.value.add(_mineCurrent);
    _mineCurrent = MessageModel(isMine: true);
    messages.notifyListeners();
    _textController.clear();
    clearFileSelection();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  void addMyText(String text) {
    _mineCurrent.message = text;
  }

  void pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) {
        return;
      }
      File file = File(result.files.single.path!);
      var extension = resolveMessageType(p.extension(file.path));
      var bytes = await file.readAsBytes();
      _mineCurrent.data = bytes;
      _mineCurrent.type = extension;
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
    _mineCurrent.data = null;
    _mineCurrent.type = null;
    setState(() {});
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
                      return MessageTile(model: value[index]);
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
                  icon: _mineCurrent.data == null ? Icon(Icons.attach_file) : Icon(Icons.clear),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                    backgroundColor: WidgetStateProperty.all(Colors.cyan[900]),
                  ),
                  onPressed: () {
                    if (_mineCurrent.data == null) {
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
  int? sender;
  Uint8List? data;
  String? message;
  MessageStatus? status;
  String? timeStamp;
  MessageType? type;
  bool? isMine;

  MessageModel({this.id, this.sender, this.data, this.message, this.status, this.timeStamp, this.type, this.isMine});

  @override
  String toString() {
    return 'MessageModel{id: $id, sender: $sender,  message: $message, status: $status, timeStamp: $timeStamp, type: $type, isMine: $isMine}';
  }
}
