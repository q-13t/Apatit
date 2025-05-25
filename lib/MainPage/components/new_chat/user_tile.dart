import 'dart:convert';
import 'dart:typed_data';

import 'package:apatite/api/network_controller.dart';
import 'package:apatite/models/user_tile_model.dart';
import 'package:apatite/utils/enums.dart';
import 'package:apatite/utils/logger.dart';
import 'package:flutter/material.dart';

class UserTile extends StatefulWidget {
  final UserTileModel model;
  const UserTile({super.key, required this.model});

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  ValueNotifier<Uint8List?> pfpNotifier = ValueNotifier<Uint8List?>(null);
  // ignore: unused_field
  static late Logger _logger;

  @override
  void initState() {
    super.initState();
    _logger = Logger("UserTile");
    final cached = NetworkController.getCachedPFP(widget.model.username);

    if (cached == null) {
      NetworkController.messageStreamController.stream.listen((message) {
        var data = jsonDecode(message.toString());
        if (data['type'] == WSMTWrapper[WSMType.getPFP] && data['username'] == widget.model.username) {
          // _logger.debug("Got PFP: ${data['bytes']}");
          var str = data['bytes'].toString();
          var bytes = (str == "null") ? Uint8List(0) : base64Decode(str);
          NetworkController.setCachedPFP(widget.model.username, bytes);
          pfpNotifier.value = bytes;
        }
      });
      NetworkController.websocketSend({'username': widget.model.username}, WSMType.getPFP);
    } else {
      pfpNotifier.value = cached;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ValueListenableBuilder(
          valueListenable: pfpNotifier,
          builder: (context, value, child) {
            if (value == null) {
              return CircularProgressIndicator();
            } else if (value.isEmpty) {
              return CircleAvatar(child: Icon(Icons.person));
            } else {
              return CircleAvatar(child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.memory(value)));
            }
          },
        ),
        SizedBox(width: 10),
        Text(widget.model.username, style: TextStyle(fontSize: 20)),
      ],
    );
  }
}
