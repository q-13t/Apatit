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
      body: Placeholder(),
    );
  }
}
