import 'package:apatite/utils/enums.dart' show Pages;
import 'package:flutter/material.dart';

class ControlDrawer extends StatefulWidget {
  final Function changePage;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ControlDrawer({
    super.key,
    required this.changePage,
    required this.scaffoldKey,
  });

  @override
  State<ControlDrawer> createState() => _ControlDrawerState();
}

class _ControlDrawerState extends State<ControlDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromARGB(255, 12, 142, 165)),
            child: Text('Drawer Header', style: TextStyle(fontSize: 24)),
          ),
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Messages'),
                onTap: () {
                  widget.changePage(Pages.chats);
                  widget.scaffoldKey.currentState?.closeDrawer();
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Profile'),
                onTap: () {
                  widget.changePage(Pages.profile);
                  widget.scaffoldKey.currentState?.closeDrawer();
                },
              ),
            ],
          ),
          Spacer(flex: 1),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              widget.changePage(Pages.settings);
              widget.scaffoldKey.currentState?.closeDrawer();
            },
          ),
        ],
      ),
    );
  }
}
