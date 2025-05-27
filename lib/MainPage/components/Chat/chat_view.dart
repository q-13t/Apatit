import 'package:apatite/MainPage/components/Chat/elements/message_tile.dart';
import 'package:apatite/MainPage/components/empty_widget.dart';
import 'package:apatite/models/chat_tile_model.dart';
import 'package:apatite/utils/enums.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    messages.value = List.generate(20, (index) => MessageModel(id: index, sender: index.isEven ? widget.model.id : 0, data: 'Message $index', status: MessageStatus.sent, timeStamp: DateTime.now().toString(), type: MessageType.text, isMine: index.isEven));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.model.name), leading: IconButton(onPressed: () => widget.changePage(Pages.chats), icon: Icon(Icons.arrow_back))),
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
                  return ValueListenableBuilder(
                    valueListenable: messages,
                    builder: (context, value, child) {
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return MessageTile(model: value[index]);
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
                Expanded(child: TextField(decoration: InputDecoration(hintText: 'Type a message', border: OutlineInputBorder()))),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  style: ButtonStyle(shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))), backgroundColor: WidgetStateProperty.all(Colors.cyan[900])),
                  onPressed: () {
                    // Handle attach button press
                  },
                ),
                IconButton(
                  style: ButtonStyle(shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))), backgroundColor: WidgetStateProperty.all(Colors.cyan[900])),
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Handle send button press
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

  MessageModel({required this.id, required this.sender, required this.data, required this.status, required this.timeStamp, required this.type, required this.isMine});

  @override
  String toString() {
    return 'MessageModel{id: $id, sender: $sender, data: $data, status: $status, timeStamp: $timeStamp, type: $type, isMine: $isMine}';
  }
}
