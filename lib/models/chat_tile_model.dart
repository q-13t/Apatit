import 'package:flutter/services.dart';

class ChatTileModel {
  int id;
  String name;
  String? pfpUUID;
  String? lastMessage;
  Uint8List? pfp;

  ChatTileModel({required this.id, required this.name, this.pfpUUID, this.lastMessage});

  factory ChatTileModel.fromJson(Map<String, dynamic> json) {
    return ChatTileModel(id: json['id'], name: json['name'], pfpUUID: json['pfp'], lastMessage: json['lastMessage']);
  }
}
