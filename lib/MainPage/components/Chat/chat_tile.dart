import 'package:apatite/models/chat_tile_model.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatefulWidget {
  final ChatTileModel data;

  const ChatTile({super.key, required this.data});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(8.0), margin: const EdgeInsets.all(8.0), child: Row(children: <Widget>[Icon(Icons.message), Text(widget.data.name)]));
  }
}
