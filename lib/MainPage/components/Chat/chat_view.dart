import 'dart:math';

import 'package:apatite/MainPage/components/Chat/elements/message_tile.dart';
import 'package:apatite/MainPage/components/empty_widget.dart';
import 'package:apatite/models/chat_tile_model.dart';
import 'package:apatite/utils/enums.dart';
import 'package:apatite/utils/logger.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    messages.value = List.generate(
      20,
      (index) => MessageModel(
        id: index,
        sender: index.isEven ? widget.model.id : 0,
        data: List.generate(Random().nextInt(150) + 1, (index) => 'x').join(),
        status: MessageStatus.values.elementAt(Random().nextInt(MessageStatus.values.length)),
        timeStamp: DateTime.now().toString(),
        type: MessageType.values.elementAt(Random().nextInt(MessageType.values.length)),
        isMine: index.isEven,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void sendMessage() {
    addMyText(myInput);
    _logger.debug("Messages: ${myInput}");
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void addMyText(String text) {
    messages.value.add(
      MessageModel(
        id: messages.value.length,
        sender: widget.model.id,
        data: text,
        status: MessageStatus.sent,
        timeStamp: DateTime.now().toString(),
        type: MessageType.text,
        isMine: true,
      ),
    );
    messages.notifyListeners();
    _textController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 2),
        curve: Curves.easeInOut,
      );
    });
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
                    onChanged: (value) => {myInput = value},
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                    backgroundColor: WidgetStateProperty.all(Colors.cyan[900]),
                  ),
                  onPressed: () {
                    // Handle attach button press
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
  final int id;
  final int sender;
  final String data;
  final MessageStatus status;
  final String timeStamp;
  final MessageType type;
  final bool isMine;

  MessageModel({
    required this.id,
    required this.sender,
    required this.data,
    required this.status,
    required this.timeStamp,
    required this.type,
    required this.isMine,
  });

  @override
  String toString() {
    return 'MessageModel{id: $id, sender: $sender, data: $data, status: $status, timeStamp: $timeStamp, type: $type, isMine: $isMine}';
  }
}
