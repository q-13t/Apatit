import 'package:Apatite/models/chat_tile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatTile extends StatefulWidget {
  final ChatTileModel model;
  final Function selectChat;

  const ChatTile({super.key, required this.model, required this.selectChat});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SizedBox(
        height: 75,
        child: ElevatedButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
          onPressed: () => {widget.selectChat(widget.model)},
          child: Row(
            children: <Widget>[
              CircleAvatar(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: widget.model.pfp == 0 ? Icon(Icons.person) : Image.memory(Uint8List(0)),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.model.name, textAlign: TextAlign.start, style: TextStyle(fontSize: 20)),
                      Text(
                        widget.model.lastMessage,
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // return Container(padding: const EdgeInsets.all(8.0), margin: const EdgeInsets.all(8.0), child: Row(children: <Widget>[Icon(Icons.message), Text(widget.model.name)]));
  }
}
