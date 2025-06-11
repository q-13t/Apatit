import 'package:Apatite/MainPage/components/Chat/chats_controller.dart';
import 'package:Apatite/MainPage/components/control_drawer.dart';
import 'package:Apatite/MainPage/components/settings_page.dart';
import 'package:Apatite/models/chat_tile_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:flutter/material.dart';

class MainPageController extends StatefulWidget {
  const MainPageController({super.key});
  @override
  State<MainPageController> createState() => MainPageControllerState();
}

class MainPageControllerState extends State<MainPageController> {
  static ValueNotifier<Pages> currentPage = ValueNotifier(Pages.chats);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  static ChatTileModel chatData = ChatTileModel(id: 0, name: "Chat_1", pfpUUID: "0", lastMessage: "Last message");
  // ignore: unused_field
  final _logger = Logger("MainPageController");

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
    if (currentPage.value == Pages.settings) {
      return Scaffold(key: _scaffoldKey, appBar: AppBar(title: const Text('Setting')), drawer: ControlDrawer(changePage: changePage, scaffoldKey: _scaffoldKey), body: Center(child: SettingsPage()));
    } else if (currentPage.value == Pages.chats) {
      return ChatsList(changePage: changePage, scaffoldKey: _scaffoldKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(builder: (context, value, child) => getCurrentPage(), valueListenable: currentPage);
  }
}
