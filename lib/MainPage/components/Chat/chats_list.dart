import 'package:apatite/MainPage/components/Chat/chat_head.dart';
import 'package:apatite/utils/models.dart';
import 'package:flutter/material.dart';

class ChatsList extends StatefulWidget {
  final Function selectChat;

  const ChatsList({super.key, required this.selectChat});

  @override
  _ChatsListState createState() => _ChatsListState();
}

class _ChatsListState extends State<ChatsList> {
  // TODO: Implement Networking chat request
  var chats = [
    ChatHeadModel(1, "Chat Name 1"),
    ChatHeadModel(2, "Chat Name 2"),
    ChatHeadModel(3, "Chat Name 3"),
    ChatHeadModel(4, "Chat Name 4"),
    ChatHeadModel(5, "Chat Name 5"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        for (var ch in chats)
          GestureDetector(
            onTap: () => widget.selectChat(ch),
            child: Card(child: ChatHead(chat: ch)),
          ),
      ],
    );
  }
}
