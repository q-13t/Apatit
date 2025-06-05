import 'package:Apatite/MainPage/components/Chat/chat_view.dart';
import 'package:Apatite/MainPage/components/Chat/elements/audio_player.dart';
import 'package:Apatite/MainPage/components/Chat/elements/video_player.dart';
import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/models/message_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final MessageModel message;
  static final Logger logger = Logger("MessageTile");

  const MessageTile({super.key, required this.message});

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            Row(
              children: [
                CircleAvatar(
                  child:
                      (ChatViewState.participants.firstWhere((element) => element.id == widget.message.sender).pfp !=
                              null)
                          ? Image.memory(
                            ChatViewState.participants
                                .firstWhere((element) => element.id == widget.message.sender)
                                .pfp!,
                          )
                          : Icon(Icons.person),
                ),
                const SizedBox(width: 10),
                Text(
                  ChatViewState.participants.firstWhere((element) => element.id == widget.message.sender).username,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Container(height: 2, width: double.infinity, color: Colors.cyan[500]),
            ),
            buildMedia(context, widget.message),
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

  Widget buildMedia(BuildContext context, MessageModel model) {
    return FutureBuilder(
      future: NetworkController.getFile(model.fileUuid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return Container();
          }
          switch (model.type) {
            case MessageType.image:
              return Image(key: UniqueKey(), image: MemoryImage(snapshot.data!.readAsBytesSync()));
            case MessageType.video:
              return CustomVideoPlayer(key: UniqueKey(), data: snapshot.data);
            case MessageType.audio:
              return CustomAudioPlayer(key: UniqueKey(), data: snapshot.data);
            case MessageType.file:
              return Placeholder();
            default:
              return Container();
          }
        } else {
          return Container();
        }
      },
    );
  }

  getIcon(BuildContext context, MessageStatus type) {
    switch (type) {
      case MessageStatus.delivered:
        return Icon(Icons.done_outline_rounded, size: 15);
      case MessageStatus.seen:
        return Icon(Icons.done_all, size: 15);
      case MessageStatus.sent:
        return Icon(Icons.done, size: 15);
    }
  }
}
