import 'package:apatite/MainPage/components/Chat/ChatHead.dart';
import 'package:apatite/utils/Enums.dart';
import 'package:apatite/utils/Models.dart';
import 'package:flutter/material.dart';

class ChatsController extends StatefulWidget {
  final Function changePage;
  final Function setChatData;

  const ChatsController({
    super.key,
    required this.changePage,
    required this.setChatData,
  });

  @override
  State<ChatsController> createState() => _ChatsControllerState();
}

class _ChatsControllerState extends State<ChatsController> {
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
            onTap: () => widget.changePage(Pages.chat),
            child: Card(
              child: ChatHead(
                chat: ch,
                changePage: widget.changePage,
                setChatData: widget.setChatData,
              ),
            ),
          ),
      ],
    );
  }
}
