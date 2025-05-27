import 'package:apatite/MainPage/components/Chat/chat_view.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final MessageModel model;

  const MessageTile({super.key, required this.model});

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    if (widget.model.isMine) {
      return buildMineMessage(context, widget.model);
    }
    return buildIncomingMessage(context, widget.model);
  }

  Widget buildMineMessage(BuildContext context, MessageModel model) {
    return Text(model.data);
  }

  Widget buildIncomingMessage(BuildContext context, MessageModel model) {
    return Text(model.data);
  }
}
