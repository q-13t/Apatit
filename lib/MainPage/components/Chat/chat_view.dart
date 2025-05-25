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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();
    // return Scaffold(
    //   appBar: AppBar(title: Text(widget.chatData.name), leading: IconButton(onPressed: () => widget.changePage(Pages.chats), icon: Icon(Icons.arrow_back))),
    //   body: ListView.builder(itemCount: messages.length, controller: _scrollController, reverse: true, itemBuilder: (context, index) => Card(child: ListTile(title: Text(messages[index].message), subtitle: Text(messages[index].status.toString())))),
    //   bottomNavigationBar: Padding(
    //     padding: const EdgeInsets.all(8.0),
    //     child: Row(
    //       children: [
    //         Expanded(child: TextField(decoration: InputDecoration(hintText: 'Type a message', border: OutlineInputBorder()))),
    //         IconButton(
    //           icon: Icon(Icons.attach_file),
    //           onPressed: () {
    //             // Handle send button press
    //           },
    //         ),
    //         IconButton(
    //           icon: Icon(Icons.send),
    //           onPressed: () {
    //             // Handle send button press
    //           },
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
