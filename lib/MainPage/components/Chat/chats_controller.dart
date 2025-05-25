import 'dart:async';
import 'dart:convert';

import 'package:apatite/MainPage/components/Chat/chat_tile.dart';
import 'package:apatite/MainPage/components/empty_widget.dart';
import 'package:apatite/api/network_controller.dart';
import 'package:apatite/models/chat_tile_model.dart';
import 'package:apatite/utils/enums.dart';
import 'package:apatite/utils/logger.dart';
import 'package:flutter/material.dart';

class ChatsList extends StatefulWidget {
  final Function selectChat;

  const ChatsList({super.key, required this.selectChat});

  @override
  ChatsListState createState() => ChatsListState();
}

class ChatsListState extends State<ChatsList> {
  final ValueNotifier<List<ChatTileModel>> chatsNotifier = ValueNotifier([]);
  late StreamSubscription _subscription;
  final ScrollController _scrollController = ScrollController();
  final Logger _logger = Logger("ChatsList");
  int offset = 0;
  int limit = 20;
  int lastLoad = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreChats);
    chatsNotifier.value = [
      ChatTileModel(id: 0, name: "Chat_1", pfp: 0, lastMessage: "Last message"),
      ChatTileModel(id: 1, name: "Chat_2", pfp: 0, lastMessage: "Last message"),
      ChatTileModel(id: 2, name: "Chat_3", pfp: 0, lastMessage: "Last message"),
      ChatTileModel(id: 3, name: "Chat_4", pfp: 0, lastMessage: "Last message"),
      ChatTileModel(id: 4, name: "Chat_5", pfp: 0, lastMessage: "Last message"),
      ChatTileModel(id: 5, name: "Chat_6", pfp: 0, lastMessage: "Last message"),
      ChatTileModel(id: 6, name: "Chat_7", pfp: 0, lastMessage: "Last message"),
      ChatTileModel(id: 7, name: "Chat_8", pfp: 0, lastMessage: "Last message"),
      ChatTileModel(id: 8, name: "Chat_9", pfp: 0, lastMessage: "Last message"),
      ChatTileModel(id: 9, name: "Chat_10", pfp: 0, lastMessage: "Last message"),
    ];

    // _subscription = NetworkController.messageStreamController.stream.listen((message) {
    //   _logger.debug("Got message: $message");
    //   var data = jsonDecode(message.toString());
    //   if (data['type'] == WSMTWrapper[WSMType.getChats]) {
    //     var list = List.generate(data['chats'].length, (index) => ChatTileModel.fromJson(data['chats'][index]));
    //     lastLoad = list.length;
    //     chatsNotifier.value += list;
    //   }
    // });
    // NetworkController.websocketSend({'offset': offset, 'limit': limit}, WSMType.getChats);
  }

  void _loadMoreChats() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (lastLoad < limit) return;
      offset += limit;
      NetworkController.websocketSend({'offset': offset, 'limit': limit}, WSMType.getChats);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    chatsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: chatsNotifier,
              builder: (context, value, child) {
                if (value.isEmpty) {
                  return WowSoEmpty();
                }
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return ChatTile(model: value[index], selectChat: widget.selectChat);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
