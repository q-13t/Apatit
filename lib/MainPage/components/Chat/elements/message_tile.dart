import 'dart:typed_data';

import 'package:Apatite/MainPage/components/Chat/chat_view.dart';
import 'package:Apatite/MainPage/components/Chat/elements/audio_player.dart';
import 'package:Apatite/MainPage/components/Chat/elements/video_player.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final MessageModel model;

  const MessageTile({super.key, required this.model});

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  ValueNotifier<UserModel?> user = ValueNotifier(UserModel(id: 0, username: "test", pfp: 0));

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: (widget.model.isMine ?? false) ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: (widget.model.isMine ?? false) ? Colors.cyan[700] : Colors.cyan[900],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: user,
              builder: (context, value, child) {
                if (value == null) {
                  return CircleAvatar(child: Icon(Icons.person));
                } else {
                  return Row(
                    children: [
                      CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 10),
                      Text("Username", style: TextStyle(fontSize: 20)),
                    ],
                  );
                }
              },
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Container(height: 2, width: double.infinity, color: Colors.cyan[500]),
            ),
            buildMedia(context, widget.model),
            Text(widget.model.message ?? "", style: TextStyle(fontSize: 20), textAlign: TextAlign.start),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.model.timeStamp ?? "", style: TextStyle(fontSize: 15)),
                const Spacer(),
                getIcon(context, widget.model.status ?? MessageStatus.sent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMedia(BuildContext context, MessageModel model) {
    switch (model.type) {
      case MessageType.image:
        return Image(image: MemoryImage(model.data ?? Uint8List(0)));
      case MessageType.video:
        return CustomVideoPlayer(model: model);
      case MessageType.audio:
        return CustomAudioPlayer(model: model);
      case MessageType.file:
        return Placeholder();
      default:
        return Container();
    }
  }

  getIcon(BuildContext context, MessageStatus type) {
    switch (type) {
      case MessageStatus.delivered:
        return Icon(Icons.done_outline_rounded, size: 15);
      case MessageStatus.failed:
        return Icon(Icons.error, size: 15);
      case MessageStatus.seen:
        return Icon(Icons.done_all, size: 15);
      case MessageStatus.sent:
        return Icon(Icons.done, size: 15);
    }
  }
}

class UserModel {
  final String username;
  final int id;
  final int pfp;

  UserModel({required this.username, required this.id, required this.pfp});
}
