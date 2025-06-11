import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/main.dart';
import 'package:Apatite/models/chat_tile_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatTile extends StatefulWidget {
  final ChatTileModel model;
  final Function updateList;

  const ChatTile({super.key, required this.model, required this.updateList});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SizedBox(
        height: 75,
        child: GestureDetector(
          onTap: () => {selectChat(widget.model)},
          onLongPress: () {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final Offset position = renderBox.localToGlobal(Offset.zero);
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
              items: [
                PopupMenuItem(
                  child: Text('Delete chat'),
                  onTap: () {
                    NetworkController.websocketSend({'chat_id': widget.model.id}, WSMType.deleteChat);
                    widget.updateList();
                  },
                ),
                PopupMenuItem(child: Text('Rename chat'), onTap: () => {}),
              ],
            );
          },
          child: ElevatedButton(
            style: ButtonStyle(shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
            onPressed: () => {selectChat(widget.model)},
            child: Row(
              children: <Widget>[
                Hero(tag: Main.getUuid(), child: CircleAvatar(child: ClipRRect(borderRadius: BorderRadius.circular(50), child: widget.model.pfp == null ? Icon(Icons.person) : Image.memory(widget.model.pfp!)))),
                SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.model.name, textAlign: TextAlign.start, style: TextStyle(fontSize: 20)),
                        Text(widget.model.lastMessage == null ? "" : widget.model.lastMessage!, textAlign: TextAlign.start, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  selectChat(ChatTileModel model) {
    Navigator.pushNamed(context, '/chat', arguments: {'model': model});
  }
}
