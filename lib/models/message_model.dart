import 'dart:convert';
import 'dart:typed_data';

import 'package:Apatite/utils/enums.dart';

class MessageModel {
  int? id;
  String? text;
  String? timeStamp;
  int sender;
  int chatId;
  MessageStatus? status;
  String? fileUuid;
  Uint8List? data;

  MessageType? type;

  MessageModel({
    this.id,
    required this.sender,
    this.fileUuid,
    this.text,
    this.status,
    required this.chatId,
    this.timeStamp,
    this.type,
  });

  @override
  String toString() {
    return 'MessageModel{id: $id, sender: $sender,  message: $text, status: $status, timeStamp: $timeStamp, type: $type,  fileUuid: $fileUuid}';
  }

  String toJSON() {
    return jsonEncode({
      "user_id": sender,
      "chat_id": chatId,
      "text": text,
      "status": messageStatusWrapper[status].toString(),
      "timeStamp": timeStamp,
      "type": messageTypeWrapper[type].toString(),
      "file_uuid": fileUuid,
    });
  }
}
