import 'package:apatite/MainPage/components/Chat/chat_view.dart';
import 'package:apatite/MainPage/components/Chat/chats_controller.dart';
import 'package:apatite/MainPage/components/control_drawer.dart';
import 'package:apatite/MainPage/components/new_chat/new_chat_controller.dart';
import 'package:apatite/utils/enums.dart';
import 'package:flutter/material.dart';

class MainPageController extends StatefulWidget {
  const MainPageController({super.key});

  @override
  State<MainPageController> createState() => _MainPageControllerState();
}

class _MainPageControllerState extends State<MainPageController> {
  Pages selectedPage = Pages.chats;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var chatData;

  setChatData(chat) {
    setState(() {
      chatData = chat;
      selectedPage = Pages.chat;
    });
  }

  changePage(Pages page) {
    setState(() {
      selectedPage = page;
    });
  }

  getCurrentPage() {
    switch (selectedPage) {
      case Pages.chat:
        return ChatView(changePage: changePage, model: chatData);
      case Pages.chats:
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: const Text('Chat')),
          drawer: ControlDrawer(changePage: changePage, scaffoldKey: _scaffoldKey),
          body: Center(child: ChatsList(selectChat: setChatData)),
          floatingActionButton: FloatingActionButton(onPressed: () => changePage(Pages.newChat), tooltip: 'Increment', child: const Icon(Icons.new_label_outlined)),
        );

      case Pages.profile:
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: const Text('Profile')),
          drawer: ControlDrawer(changePage: changePage, scaffoldKey: _scaffoldKey),
          body: Center(child: Placeholder()), //TODO: Specify settings page
          floatingActionButton: FloatingActionButton(onPressed: () => {changePage(Pages.newChat)}, tooltip: 'Increment', child: const Icon(Icons.new_label_outlined)),
        );
      case Pages.newChat:
        return NewChatController(changePage: changePage);

      case Pages.settings:
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: const Text('Setting')),
          drawer: ControlDrawer(changePage: changePage, scaffoldKey: _scaffoldKey),
          body: Center(child: Placeholder()), //TODO: Specify settings page
          floatingActionButton: FloatingActionButton(onPressed: () => changePage(Pages.chats), tooltip: 'Increment', child: const Icon(Icons.new_label_outlined)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return getCurrentPage();
  }
}
