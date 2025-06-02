import 'package:Apatite/MainPage/components/Chat/chat_view.dart';
import 'package:Apatite/MainPage/components/Chat/chats_controller.dart';
import 'package:Apatite/MainPage/components/control_drawer.dart';
import 'package:Apatite/MainPage/components/new_chat/new_chat_controller.dart';
import 'package:Apatite/MainPage/components/settings_page.dart';
import 'package:Apatite/models/chat_tile_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:flutter/material.dart';

class MainPageController extends StatefulWidget {
  const MainPageController({super.key});

  @override
  State<MainPageController> createState() => MainPageControllerState();
}

class MainPageControllerState extends State<MainPageController> {
  static ValueNotifier<Pages> currentPage = ValueNotifier(Pages.chats);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static ChatTileModel chatData = ChatTileModel(id: 0, name: "Chat_1", pfp: "0", lastMessage: "Last message");

  setChatData(chat) {
    setState(() {
      chatData = chat;
      currentPage.value = Pages.chat;
    });
  }

  changePage(Pages page) {
    setState(() {
      currentPage.value = page;
    });
  }

  getCurrentPage() {
    switch (currentPage.value) {
      case Pages.chat:
        return ChatView(changePage: changePage, model: chatData);
      case Pages.chats:
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: const Text('Chats')),
          drawer: ControlDrawer(changePage: changePage, scaffoldKey: _scaffoldKey),
          body: Center(child: ChatsList(selectChat: setChatData)),
          floatingActionButton: FloatingActionButton(
            onPressed: () => changePage(Pages.newChat),
            tooltip: 'Increment',
            child: const Icon(Icons.new_label_outlined),
          ),
        );

      case Pages.profile:
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: const Text('Profile')),
          drawer: ControlDrawer(changePage: changePage, scaffoldKey: _scaffoldKey),
          body: Center(child: Placeholder()), //TODO: Specify profile page
          floatingActionButton: FloatingActionButton(
            onPressed: () => {changePage(Pages.newChat)},
            tooltip: 'Increment',
            child: const Icon(Icons.new_label_outlined),
          ),
        );
      case Pages.newChat:
        return NewChatController(changePage: changePage);

      case Pages.settings:
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: const Text('Setting')),
          drawer: ControlDrawer(changePage: changePage, scaffoldKey: _scaffoldKey),
          body: Center(child: SettingsPage()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(builder: (context, value, child) => getCurrentPage(), valueListenable: currentPage);
  }
}
