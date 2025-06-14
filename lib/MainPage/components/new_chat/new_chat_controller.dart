import 'dart:async';
import 'dart:convert';

import 'package:Apatite/MainPage/components/empty_widget.dart';
import 'package:Apatite/MainPage/components/new_chat/user_tile.dart';
import 'package:Apatite/MainPage/main_page_controller.dart';
import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/models/chat_tile_model.dart';
import 'package:Apatite/models/user_tile_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:Apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';

class NewChatController extends StatefulWidget {
  final ChatTileModel? model;

  const NewChatController({super.key, required this.model});

  @override
  State<NewChatController> createState() => _NewChatControllerState();
}

class _NewChatControllerState extends State<NewChatController> {
  final ValueNotifier<List<UserTileModel>> usersNotifier = ValueNotifier([]);
  late StreamSubscription _subscription;
  final ScrollController _scrollController = ScrollController();
  int offset = 0;
  int limit = 20;
  int lastLoad = 0;
  late String username;
  // ignore: unused_field
  final Logger _logger = Logger("_NewChatControllerState");

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreUsers);
    _subscription = NetworkController.messageStreamController.stream.listen((message) {
      var data = jsonDecode(message.toString());
      if (data['type'] == WSMTWrapper[WSMType.getUsersByName]) {
        var list = List.generate(data['users'].length, (index) => UserTileModel.fromMap(data['users'][index]));
        lastLoad = list.length;
        usersNotifier.value += list;
      }
    });
    NetworkController.messageStreamController.stream.listen((message) {
      var data = jsonDecode(message.toString());
      if (data['type'] == WSMTWrapper[WSMType.newChatPrivate]) {
        _logger.debug("Got new chat: ${data['chat_id']}");
        if (data['chat_id'] == null || data['id'] == -1) {
          ToastService.showToast('Chat not created');
        } else {
          MainPageControllerState.chatData = ChatTileModel(id: data['chat_id'], name: data['name']);
          MainPageControllerState.currentPage.value = Pages.chat;
        }
      }
    });
  }

  void _loadMoreUsers() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (lastLoad < limit) return;
      offset += limit;
      NetworkController.websocketSend({'username': username, 'offset': offset, 'limit': limit}, WSMType.getUsersByName);
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.model?.name ?? 'New Chat'),
        leading: IconButton(
          onPressed:
              () => {
                Navigator.pop(context, (_) => {setState(() {})}),
              },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(hintText: 'Enter Username', border: OutlineInputBorder()),
            onChanged:
                (value) => {
                  usersNotifier.value = [],
                  if (value.isNotEmpty)
                    {
                      username = value,
                      offset = 0,
                      NetworkController.websocketSend({'username': username, 'offset': offset, 'limit': limit}, WSMType.getUsersByName),
                    },
                },
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: usersNotifier,
              builder: (context, value, child) {
                if (value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ElevatedButton(
                            onPressed:
                                () => {
                                  if (widget.model == null)
                                    {
                                      NetworkController.websocketSend({'user1': value[index].id, 'user2': NetworkController.me.id}, WSMType.newChatPrivate),
                                    }
                                  else
                                    {
                                      NetworkController.addParticipantToChat(widget.model!.id, value[index].id).then(
                                        (res) => {
                                          if (res)
                                            {
                                              NetworkController.websocketSend({'chat_id': widget.model!.id, 'user_id': value[index].id, 'sender_id': NetworkController.me.id}, WSMType.addParticipant),
                                            }
                                          else
                                            {ToastService.showToast('Something went wrong')},
                                        },
                                      ),
                                    },
                                },
                            child: Padding(padding: EdgeInsets.all(5), child: UserTile(key: Key(value[index].username), model: value[index])),
                          ),
                        );
                      },
                    ),
                  );
                }
                return WowSoEmpty();
              },
            ),
          ),
        ],
      ),
    );
  }
}
