import 'dart:async';
import 'dart:convert';

import 'package:Apatite/MainPage/components/Chat/chat_tile.dart';
import 'package:Apatite/MainPage/components/empty_widget.dart';
import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/models/chat_tile_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:Apatite/utils/logger.dart';
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
  // ignore: unused_field
  final Logger _logger = Logger("ChatsList");
  int offset = 0;
  int limit = 20;
  int lastLoad = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreChats);
    _subscription = NetworkController.messageStreamController.stream.listen((message) {
      _logger.debug("Got message: $message");
      var data = jsonDecode(message.toString());
      if (data['type'] == WSMTWrapper[WSMType.getChats]) {
        var list = List.generate(data['chats'].length, (index) => ChatTileModel.fromJson(data['chats'][index]));
        lastLoad = list.length;
        chatsNotifier.value += list;
      }
    });
    NetworkController.websocketSend({'offset': offset, 'limit': limit}, WSMType.getChats);
  }

  void updateList() {
    offset = 0;
    lastLoad = 0;
    chatsNotifier.value = [];
    NetworkController.websocketSend({'offset': offset, 'limit': limit}, WSMType.getChats);
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
                    return ChatTile(model: value[index], selectChat: widget.selectChat, updateList: updateList);
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
