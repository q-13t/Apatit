// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:convert';

import 'package:Apatite/MainPage/components/Chat/chat_tile.dart';
import 'package:Apatite/MainPage/components/control_drawer.dart';
import 'package:Apatite/MainPage/components/empty_widget.dart';
import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/models/chat_tile_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:flutter/material.dart';

class ChatsList extends StatefulWidget {
  final Function changePage;
  final GlobalKey<ScaffoldState> _scaffoldKey;

  const ChatsList({super.key, required this.changePage, required GlobalKey<ScaffoldState> scaffoldKey}) : _scaffoldKey = scaffoldKey;

  @override
  ChatsListState createState() => ChatsListState();
}

class ChatsListState extends State<ChatsList> {
  final ValueNotifier<List<ChatTileModel>> chatsNotifier = ValueNotifier([]);
  late StreamSubscription _subscription;
  final ScrollController _scrollController = ScrollController();
  // ignore: unused_field
  final Logger _logger = Logger("ChatsListState");
  int offset = 0;
  int limit = 20;
  int lastLoad = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreChats);
    _subscription = NetworkController.messageStreamController.stream.listen((message) async {
      var data = jsonDecode(message.toString());
      final type = WSMType.values.firstWhere((e) => e.name == data['type'], orElse: () => WSMType.error);
      switch (type) {
        case WSMType.getChats:
          {
            List<ChatTileModel> list = [];
            for (var chat in data['chats']) {
              var chatModel = ChatTileModel.fromJson(chat);
              if (chatModel.pfpUUID != null) {
                final file = await NetworkController.getFile(chatModel.pfpUUID!);
                if (file != null) {
                  chatModel.pfp = file.readAsBytesSync();
                }
              }
              list.add(chatModel);
            }
            lastLoad = list.length;
            chatsNotifier.value += list;
            break;
          }
        case WSMType.removeParticipant:
          {
            var innerData = jsonDecode(data['data']);
            var chat = jsonDecode(innerData['chat']);
            var user = jsonDecode(innerData['user']);
            if (user['id'] != NetworkController.me.id) return;
            if (mounted) {
              Navigator.popUntil(context, ModalRoute.withName('/'));
              chatsNotifier.value.removeWhere((element) => element.id == chat['id']);
              setState(() {});
            }
            break;
          }
        case WSMType.addParticipant:
          {
            var innerData = jsonDecode(data['data']);
            var chat = jsonDecode(innerData['chat']);
            var user = jsonDecode(innerData['user']);
            if (user['id'] != NetworkController.me.id) return;
            ChatTileModel chatModel;
            if (chat["pfp"] != null) {
              var file = await NetworkController.getFile(chat["pfp"]);
              chatModel = ChatTileModel.fromJson(chat);
              chatModel.pfp = file?.readAsBytesSync();
            } else {
              chatModel = ChatTileModel.fromJson(chat);
            }
            chatsNotifier.value.removeWhere((element) => element.id == chat['id']);
            chatsNotifier.value = [chatModel, ...chatsNotifier.value];
            break;
          }
        case WSMType.updateChat:
          {
            var innerData = jsonDecode(data['data']);
            ChatTileModel model = chatsNotifier.value.firstWhere((element) => element.id == innerData['id'], orElse: () => ChatTileModel(id: -1, name: ""));
            if (model.id == -1) return;
            if (innerData['name'] != null && innerData['name'] != model.name) {
              model.name = innerData['name'];
            }
            if (model.pfpUUID != innerData['pfp'] && innerData['pfp'] != null) {
              model.pfpUUID = innerData['pfp'];
              var newPfp = await NetworkController.getFile(innerData['pfp']);
              model.pfp = newPfp?.readAsBytesSync();
            }
            chatsNotifier.value.removeWhere((element) => element.id == innerData['id']);
            chatsNotifier.value = [model, ...chatsNotifier.value];
            chatsNotifier.notifyListeners();
            break;
          }

        default:
          {
            _logger.err("Unknown message type: ${data['type']}");
            break;
          }
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
      key: widget._scaffoldKey,
      appBar: AppBar(title: const Text('Chats')),
      drawer: ControlDrawer(changePage: widget.changePage, scaffoldKey: widget._scaffoldKey),
      floatingActionButton: FloatingActionButton(onPressed: () => Navigator.pushNamed(context, '/newChat', arguments: {'model': null}), tooltip: 'Increment', child: const Icon(Icons.new_label_outlined)),
      body: Center(
        child: Scaffold(
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
                        return ChatTile(model: value[index], updateList: updateList);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
