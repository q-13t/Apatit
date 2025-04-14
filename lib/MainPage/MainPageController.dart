import 'package:apatite/MainPage/components/ControlDrawer.dart';
import 'package:apatite/utils/Enums.dart';
import 'package:flutter/material.dart';

class MainPageController extends StatefulWidget {
  const MainPageController({super.key});

  @override
  State<MainPageController> createState() => _MainPageControllerState();
}

class _MainPageControllerState extends State<MainPageController> {
  var chats = [
    {id: 1, name: 'Chat 1', messages: []},
    {id: 2, name: 'Chat 2', messages: []},
    {id: 3, name: 'Chat 3', messages: []},
    {id: 4, name: 'Chat 4', messages: []},
    {id: 5, name: 'Chat 5', messages: []},
  ];

  static var id = 0;
  static var name = '';
  static var messages = [];
  Pages selectedPage = Pages.chat;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  changePage(Pages page) {
    setState(() {
      selectedPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      drawer: ControlDrawer(changePage: changePage, scaffoldKey: _scaffoldKey),
      body: Center(
        child: Text(
          pagesWrapper[selectedPage]!,
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
