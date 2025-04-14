import 'package:apatite/MainPage/components/Chat/ChatsController.dart';
import 'package:apatite/MainPage/components/ControlDrawer.dart';
import 'package:apatite/utils/Enums.dart';
import 'package:apatite/utils/Models.dart';
import 'package:flutter/material.dart';

class MainPageController extends StatefulWidget {
  const MainPageController({super.key});

  @override
  State<MainPageController> createState() => _MainPageControllerState();
}

class _MainPageControllerState extends State<MainPageController> {
  Pages selectedPage = Pages.chat;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var chat_data;

  setChatData(chat) {
    setState(() {
      chat_data = chat;
    });
  }

  changePage(Pages page) {
    setState(() {
      selectedPage = page;
    });
  }

  getCurrentPage() {
    switch (selectedPage) {
      case Pages.chats:
        return ChatsController(
          setChatData: setChatData,
          changePage: changePage,
        );

      default:
        return const Placeholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return selectedPage == Pages.chat
        ? Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Some chat Name'),
            leading: IconButton(
              onPressed: () => changePage(Pages.chats),
              icon: Icon(Icons.arrow_back),
            ),
          ),
          body: Placeholder(),
        )
        : Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: const Text('Flutter Demo Home Page')),
          drawer: ControlDrawer(
            changePage: changePage,
            scaffoldKey: _scaffoldKey,
          ),
          body: Center(child: getCurrentPage()),
          floatingActionButton: FloatingActionButton(
            onPressed: () => changePage(Pages.chats),
            tooltip: 'Increment',
            child: const Icon(Icons.new_label_outlined),
          ),
        );
  }
}
