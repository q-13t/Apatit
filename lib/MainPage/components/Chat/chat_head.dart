import 'package:apatite/utils/models.dart';
import 'package:flutter/material.dart';

class ChatHead extends StatefulWidget {
  final ChatHeadModel chat;

  const ChatHead({super.key, required this.chat});

  @override
  State<ChatHead> createState() => _ChatHeadState();
}

class _ChatHeadState extends State<ChatHead> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[Icon(Icons.message), Text(widget.chat.name)],
      ),
    );
  }
}
