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
      "id": id,
      "user_id": sender,
      "chat_id": chatId,
      "text": text,
      "status": status!.name,
      "timeStamp": timeStamp,
      "type": type,
      "file_uuid": fileUuid,
    });
  }

  Map<String, dynamic> toDynamic() {
    return {
      "id": id,
      "user_id": sender,
      "chat_id": chatId,
      "text": text,
      "status": status!.name,
      "timeStamp": timeStamp,
      "type": type!.name,
      "file_uuid": fileUuid,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status &&
          text == other.text; // etc

  @override
  int get hashCode => id.hashCode ^ status.hashCode ^ text.hashCode ^ timeStamp.hashCode;

  MessageModel copyWith({
    int? id,
    int? sender,
    String? text,
    MessageStatus? status,
    String? timeStamp,
    MessageType? type,
    String? fileUuid,
    int? chatId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      status: status ?? this.status,
      timeStamp: timeStamp ?? this.timeStamp,
      type: type ?? this.type,
      fileUuid: fileUuid ?? this.fileUuid,
      chatId: chatId ?? this.chatId,
    );
  }
}
