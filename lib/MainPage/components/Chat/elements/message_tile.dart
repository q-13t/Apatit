import 'dart:io';

import 'package:Apatite/MainPage/components/Chat/chat_view.dart';
import 'package:Apatite/MainPage/components/Chat/elements/audio_player.dart';
import 'package:Apatite/MainPage/components/Chat/elements/file_downloader.dart';
import 'package:Apatite/MainPage/components/Chat/elements/video_player.dart';
import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/main.dart';
import 'package:Apatite/models/message_model.dart';
import 'package:Apatite/models/user_model.dart';
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
    MessageTile.logger.info("Building message tile ${widget.message.text}");

    return Align(
      alignment: (widget.message.sender == NetworkController.me.id) ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: (widget.message.sender == NetworkController.me.id) ? Colors.cyan[700] : Colors.cyan[900]),
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: Main.getUuid(),
                    child: CircleAvatar(
                      child:
                          (ChatViewState.participants.firstWhere((u) => u.id == widget.message.sender, orElse: () => User(widget.message.sender, "Missing", null)).pfp != null)
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.memory(
                                  ChatViewState.participants.firstWhere((u) => u.id == widget.message.sender, orElse: () => User(widget.message.sender, "Missing", null)).pfp!,
                                  key: ValueKey<String>(widget.message.fileUuid ?? 'no-file-${widget.message.id}'),
                                ),
                              )
                              : const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(ChatViewState.participants.firstWhere((u) => u.id == widget.message.sender, orElse: () => User(widget.message.sender, "Missing", null)).username, style: const TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 5),
              buildMedia(context, widget.message),
              Text(widget.message.text ?? "", style: const TextStyle(fontSize: 20, color: Colors.white), softWrap: true),

              Row(mainAxisSize: MainAxisSize.min, children: [Text(widget.message.timeStamp ?? "", style: const TextStyle(fontSize: 15)), const Spacer(), getIcon(context, widget.message.status ?? MessageStatus.sent)]),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMedia(BuildContext context, MessageModel model) {
    return FutureBuilder<File?>(
      future: NetworkController.getFile(model.fileUuid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final file = snapshot.data!;
        switch (model.type) {
          case MessageType.image:
            return Column(children: [Image(key: ValueKey<String>(model.fileUuid!), image: MemoryImage(file.readAsBytesSync())), FileDownloader(file: file)]);
          case MessageType.video:
            return Column(children: [CustomVideoPlayer(key: ValueKey<String>(model.fileUuid!), data: file), FileDownloader(file: file)]);
          case MessageType.audio:
            return Column(children: [CustomAudioPlayer(key: ValueKey<String>(model.fileUuid!), data: file), FileDownloader(file: file)]);
          case MessageType.file:
            return FileDownloader(key: ValueKey<String>(model.fileUuid!), file: file);
          case null:
            throw UnimplementedError();
          case MessageType.text:
            throw Container();
        }
      },
    );
  }

  Widget getIcon(BuildContext context, MessageStatus status) {
    switch (status) {
      case MessageStatus.delivered:
        return const Icon(Icons.done_outline_rounded, size: 15);
      case MessageStatus.seen:
        return const Icon(Icons.done_all, size: 15);
      case MessageStatus.sent:
        return const Icon(Icons.done, size: 15);
    }
  }
}
