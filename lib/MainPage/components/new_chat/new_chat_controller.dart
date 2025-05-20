import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:apatite/MainPage/components/empty_windget%F0%9F%8C%BB.dart';
import 'package:apatite/MainPage/components/new_chat/user_tile.dart';
import 'package:apatite/api/network_controller.dart';
import 'package:apatite/model/user_tile_model.dart';
import 'package:apatite/utils/enums.dart';
import 'package:flutter/material.dart';

class NewChatController extends StatefulWidget {
  final Function(Pages page) changePage;

  const NewChatController({super.key, required this.changePage});

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
      appBar: AppBar(title: Text('New Chat'), leading: IconButton(onPressed: () => {widget.changePage(Pages.chats)}, icon: Icon(Icons.arrow_back))),
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
                // log("ListView Builder: ${value.toString()}");
                if (value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: ElevatedButton(onPressed: () => {log(value[index].username)}, child: Padding(padding: EdgeInsets.all(5), child: UserTile(key: Key(value[index].username), model: value[index]))));
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

// class _NewChatControllerState extends State<NewChatController> {
//   final ValueNotifier<List<dynamic>> usersNotifier = ValueNotifier([]);
//   late StreamSubscription _subscription;
//   final ScrollController _scrollController = ScrollController();
//   int offset = 0;
//   int limit = 20;
//   int lastLoad = 0;
//   late String username;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_loadMoreUsers);
//     _subscription = NetworkController.messageStreamController.stream.listen((message) {
//       var data = jsonDecode(message.toString());
//       if (data['type'] == WSMTWrapper[WSMType.getUsersByName]) {
//         var list = List.from(data['users']);
//         lastLoad = list.length;
//         usersNotifier.value += list;
//       }
//     });
//   }

//   void _loadMoreUsers() {
//     if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
//       if (lastLoad < limit) return;
//       offset += limit;
//       NetworkController.websocketSend({'username': username, 'offset': offset, 'limit': limit}, WSMType.getUsersByName);
//     }
//   }

//   @override
//   void dispose() {
//     _subscription.cancel();
//     usersNotifier.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(title: Text('New Chat'), leading: IconButton(onPressed: () => {widget.changePage(Pages.chats)}, icon: Icon(Icons.arrow_back))),
//       body: Column(
//         children: [
//           TextField(
//             decoration: InputDecoration(hintText: 'Enter Username', border: OutlineInputBorder()),
//             onChanged:
//                 (value) => {
//                   usersNotifier.value = [],
//                   if (value.isNotEmpty)
//                     {
//                       username = value,
//                       offset = 0,
//                       NetworkController.websocketSend({'username': username, 'offset': offset, 'limit': limit}, WSMType.getUsersByName),
//                     },
//                 },
//           ),
//           Expanded(
//             child: ValueListenableBuilder(
//               valueListenable: usersNotifier,
//               builder: (context, value, child) {
//                 // log("ListView Builder: ${value.toString()}");
//                 if (value.isNotEmpty) {
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: ListView.builder(
//                       controller: _scrollController,
//                       shrinkWrap: true,
//                       itemCount: value.length,
//                       itemBuilder: (context, index) {
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 5),
//                           child: ElevatedButton(onPressed: () => {log(value[index]['username'])}, child: Padding(padding: EdgeInsets.all(5), child: UserTile(key: Key(value[index]['username']), username: value[index]['username'], id: value[index]['id'], pfp: value[index]['pfp']))),
//                         );
//                       },
//                     ),
//                   );
//                 }
//                 return WowSoEmpty();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
