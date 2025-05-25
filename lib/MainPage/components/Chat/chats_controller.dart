import 'dart:async';
import 'dart:convert';

import 'package:apatite/MainPage/components/Chat/chat_tile.dart';
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
  final ValueNotifier<List<ChatTileModel>> usersNotifier = ValueNotifier([]);
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
    _subscription = NetworkController.messageStreamController.stream.listen((message) {
      _logger.debug("Got message: $message");
      var data = jsonDecode(message.toString());
      if (data['type'] == WSMTWrapper[WSMType.getChats]) {
        var list = List.generate(data['chats'].length, (index) => ChatTileModel.fromJson(data['chats'][index]));
        lastLoad = list.length;
        usersNotifier.value += list;
      }
    });
    NetworkController.websocketSend({'token': NetworkController.token, 'offset': offset, 'limit': limit}, WSMType.getChats);
  }

  void _loadMoreChats() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (lastLoad < limit) return;
      offset += limit;
      NetworkController.websocketSend({'token': NetworkController.token, 'offset': offset, 'limit': limit}, WSMType.getChats);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    usersNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
