import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/utils/enums.dart' show Pages;
import 'package:flutter/material.dart';

class ControlDrawer extends StatefulWidget {
  final Function changePage;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ControlDrawer({super.key, required this.changePage, required this.scaffoldKey});

  @override
  State<ControlDrawer> createState() => _ControlDrawerState();
}

class _ControlDrawerState extends State<ControlDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    image:
                        NetworkController.me.pfp != null
                            ? DecorationImage(image: MemoryImage(NetworkController.me.pfp!), fit: BoxFit.fitWidth)
                            : null,
                  ),
                  child: Text(
                    NetworkController.me.username,
                    style: const TextStyle(fontSize: 24, color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Color.fromARGB(95, 12, 142, 165)),
              iconColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              minimumSize: WidgetStateProperty.all(Size(60, 60)),
              padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 10, horizontal: 5)),
            ),
            onPressed: () {
              widget.changePage(Pages.chats);
              widget.scaffoldKey.currentState?.closeDrawer();
            },
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: Row(children: [const Icon(Icons.message), const Text('Chats')]),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Color.fromARGB(95, 12, 142, 165)),
              iconColor: WidgetStateProperty.all(Colors.white),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              minimumSize: WidgetStateProperty.all(Size(60, 60)),
              padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 10, horizontal: 5)),
            ),
            onPressed: () {
              widget.changePage(Pages.settings);
              widget.scaffoldKey.currentState?.closeDrawer();
            },
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: Row(children: [const Icon(Icons.settings), const Text('Settings')]),
            ),
          ),
          Spacer(),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.redAccent[200]),
              iconColor: WidgetStateProperty.all(Colors.black),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              minimumSize: WidgetStateProperty.all(Size(60, 60)),
            ),
            onPressed: () {
              NetworkController.logout();
              widget.scaffoldKey.currentState?.closeDrawer();
            },
            child: Padding(
              padding: EdgeInsets.only(left: 5),
              child: Row(children: [const Icon(Icons.logout), const Text('logout')]),
            ),
          ),
        ],
      ),
    );
  }
}
