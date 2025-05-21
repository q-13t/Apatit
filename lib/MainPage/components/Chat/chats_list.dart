import 'package:apatite/MainPage/components/Chat/chat_head.dart';
import 'package:apatite/utils/models.dart';
import 'package:flutter/material.dart';

class ChatsList extends StatefulWidget {
  final Function selectChat;

  const ChatsList({super.key, required this.selectChat});

  @override
  ChatsListState createState() => ChatsListState();
}

class ChatsListState extends State<ChatsList> {
  // TODO: Implement Networking chat request
  var chats = [
    ChatHeadModel(1, "Chat Name 1"),
    ChatHeadModel(2, "Chat Name 2"),
    ChatHeadModel(3, "Chat Name 3"),
    ChatHeadModel(4, "Chat Name 4"),
    ChatHeadModel(5, "Chat Name 5"),
    ChatHeadModel(6, "Chat Name 6"),
    ChatHeadModel(7, "Chat Name 7"),
    ChatHeadModel(8, "Chat Name 8"),
    ChatHeadModel(9, "Chat Name 9"),
    ChatHeadModel(10, "Chat Name 10"),
    ChatHeadModel(11, "Chat Name 11"),
    ChatHeadModel(12, "Chat Name 12"),
    ChatHeadModel(13, "Chat Name 13"),
    ChatHeadModel(14, "Chat Name 14"),
    ChatHeadModel(15, "Chat Name 15"),
    ChatHeadModel(16, "Chat Name 16"),
    ChatHeadModel(17, "Chat Name 17"),
    ChatHeadModel(18, "Chat Name 18"),
    ChatHeadModel(19, "Chat Name 19"),
    ChatHeadModel(20, "Chat Name 20"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(children: <Widget>[for (var ch in chats) GestureDetector(onTap: () => widget.selectChat(ch), child: Card(child: ChatHead(chat: ch)))]);
  }
}
