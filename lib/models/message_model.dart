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

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      sender: json['user_id'],
      text: json['text'],
      status: MessageStatus.values.byName(json['status']),
      timeStamp: json['timeStamp'],
      type: MessageType.values.byName(json['type']),
      fileUuid: json['file_uuid'],
      chatId: json['chat_id'],
    );
  }

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

  Map<String, dynamic> toDynamic() {
    return {
      "user_id": sender,
      "chat_id": chatId,
      "text": text,
      "status": messageStatusWrapper[status].toString(),
      "timeStamp": timeStamp,
      "type": messageTypeWrapper[type].toString(),
      "file_uuid": fileUuid,
    };
  }
}
