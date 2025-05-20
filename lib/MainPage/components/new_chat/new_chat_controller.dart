import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:apatite/MainPage/components/new_chat/user_tile.dart';
import 'package:apatite/api/network_controller.dart';
import 'package:apatite/utils/enums.dart';
import 'package:flutter/material.dart';

class NewChatController extends StatefulWidget {
  final Function(Pages page) changePage;

  const NewChatController({super.key, required this.changePage});

  @override
  State<NewChatController> createState() => _NewChatControllerState();
}

class _NewChatControllerState extends State<NewChatController> {
  final ValueNotifier<List<dynamic>> usersNotifier = ValueNotifier([]);
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = NetworkController.messageStreamController.stream.listen((message) {
      var data = jsonDecode(message.toString());
      if (data['type'] == webSocketMessageTypeWrapper[WebSocketMessageType.getUsersByName]) {
        usersNotifier.value = List.from(data['users']);
      }
    });
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
      appBar: AppBar(title: Text('New Chat'), leading: IconButton(onPressed: () => {widget.changePage(Pages.chats)}, icon: Icon(Icons.arrow_back))),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(hintText: 'Enter Username', border: OutlineInputBorder()),
            onChanged:
                (value) => {
                  if (value.isNotEmpty)
                    {
                      NetworkController.websocketSend({'username': value, 'offset': 0, 'limit': 10}, WebSocketMessageType.getUsersByName),
                    }
                  else
                    {usersNotifier.value = []},
                },
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: usersNotifier,
              builder: (context, value, child) {
                log("ListView Builder: ${value.toString()}");
                if (value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return Padding(padding: EdgeInsets.symmetric(vertical: 5), child: UserTile(username: value[index]['username'], id: value[index]['id'], pfp: value[index]['pfp']));
                      },
                    ),
                  );
                }
                return Text("Wow so empty🌻");
              },
            ),
          ),
        ],
      ),
    );
  }
}
