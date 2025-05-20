import 'package:apatite/utils/enums.dart';
import 'package:apatite/utils/models.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  final Function changePage;

  final ChatHeadModel chatData;

  const ChatView({super.key, required this.changePage, required this.chatData});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  var messages = [
    MessageModel(
      1,
      "Text 1",
      MessageType.text,
      MessageStatus.sent,
      DateTime.now(),
    ),
    MessageModel(
      2,
      "Text 2",
      MessageType.text,
      MessageStatus.sent,
      DateTime.now(),
    ),
    MessageModel(
      3,
      "Text 3",
      MessageType.text,
      MessageStatus.delivered,
      DateTime.now(),
    ),
    MessageModel(
      4,
      "Text 4",
      MessageType.text,
      MessageStatus.seen,
      DateTime.now(),
    ),
    MessageModel(
      5,
      "Text 5",
      MessageType.text,
      MessageStatus.read,
      DateTime.now(),
    ),
    MessageModel(
      6,
      "Text 6",
      MessageType.text,
      MessageStatus.failed,
      DateTime.now(),
    ),
    MessageModel(
      7,
      "Text 7",
      MessageType.text,
      MessageStatus.sent,
      DateTime.now(),
    ),
    MessageModel(
      8,
      "Text 8",
      MessageType.text,
      MessageStatus.sent,
      DateTime.now(),
    ),
    MessageModel(
      9,
      "Text 9",
      MessageType.text,
      MessageStatus.sent,
      DateTime.now(),
    ),
    MessageModel(
      10,
      "Text 10",
      MessageType.text,
      MessageStatus.sent,
      DateTime.now(),
    ),
    MessageModel(
      11,
      "Text 11",
      MessageType.text,
      MessageStatus.sent,
      DateTime.now(),
    ),
    MessageModel(
      12,
      "Text 12",
      MessageType.text,
      MessageStatus.sent,
      DateTime.now(),
    ),
  ];
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    messages.sort((a, b) => b.id.compareTo(a.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatData.name),
        leading: IconButton(
          onPressed: () => widget.changePage(Pages.chats),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        controller: _scrollController,
        reverse: true,
        itemBuilder:
            (context, index) => Card(
              child: ListTile(
                title: Text(messages[index].message),
                subtitle: Text(messages[index].status.toString()),
              ),
            ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.attach_file),
              onPressed: () {
                // Handle send button press
              },
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                // Handle send button press
              },
            ),
          ],
        ),
      ),
    );
  }
}
