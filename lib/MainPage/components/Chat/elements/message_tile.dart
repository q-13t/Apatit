import 'package:Apatite/MainPage/components/Chat/chat_view.dart';
import 'package:Apatite/MainPage/components/Chat/elements/audio_player.dart';
import 'package:Apatite/MainPage/components/Chat/elements/video_player.dart';
import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/models/user_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final MessageModel message;
  final User user;

  const MessageTile({super.key, required this.message, required this.user});

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: (widget.message.sender == NetworkController.me.id) ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: (widget.message.sender == NetworkController.me.id) ? Colors.cyan[700] : Colors.cyan[900],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ValueListenableBuilder(
            //   valueListenable: widget.user,
            //   builder: (context, value, child) {
            //     if (value == null) {
            //       return CircleAvatar(child: Icon(Icons.person));
            //     } else {
            Row(
              children: [
                CircleAvatar(child: widget.user.pfp != null ? Image.memory(widget.user.pfp!) : Icon(Icons.person)),
                const SizedBox(width: 10),
                Text(widget.user.username, style: TextStyle(fontSize: 20)),
              ],
            ),

            //     }
            //   },
            // ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Container(height: 2, width: double.infinity, color: Colors.cyan[500]),
            ),
            FutureBuilder(
              future: buildMedia(context, widget.message),
              builder: (context, snapshot) => snapshot.data ?? CircularProgressIndicator(),
            ),
            Text(widget.message.text ?? "", style: TextStyle(fontSize: 20), textAlign: TextAlign.start),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.message.timeStamp ?? "", style: TextStyle(fontSize: 15)),
                const Spacer(),
                getIcon(context, widget.message.status ?? MessageStatus.sent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<Widget> buildMedia(BuildContext context, MessageModel model) async {
    var data = model.data;
    if (model.sender != NetworkController.me.id) {
      data = await NetworkController.getFile(model.fileUuid);
    }
    if (data == null) return Container();

    switch (model.type) {
      case MessageType.image:
        return Image(image: MemoryImage(data));
      case MessageType.video:
        return CustomVideoPlayer(data: data);
      case MessageType.audio:
        return CustomAudioPlayer(data: data);
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
