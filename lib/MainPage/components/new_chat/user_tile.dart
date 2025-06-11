import 'dart:typed_data';

import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/main.dart';
import 'package:Apatite/models/user_tile_model.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:flutter/material.dart';

class UserTile extends StatefulWidget {
  final UserTileModel model;
  UserTile({super.key, required this.model});
  // ignore: unused_field
  final Logger _logger = Logger("UserTile");

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  ValueNotifier<Uint8List?> pfpNotifier = ValueNotifier<Uint8List?>(null);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FutureBuilder(
          future: NetworkController.getFile(widget.model.pfp_uuid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Uint8List? data = snapshot.data?.readAsBytesSync();
              return Hero(tag: Main.getUuid(), child: CircleAvatar(child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.memory(data!))));
            } else {
              return Hero(tag: Main.getUuid(), child: CircleAvatar(child: Icon(Icons.person)));
            }
          },
        ),
        SizedBox(width: 10),
        Text(widget.model.username, style: TextStyle(fontSize: 20)),
      ],
    );
  }
}
