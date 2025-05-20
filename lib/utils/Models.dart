import 'package:apatite/utils/enums.dart';

class ChatHeadModel {
  var id = 0;
  var name = '';

  ChatHeadModel(this.id, this.name);
}

class MessageModel {
  var id = 0;
  var message = '';
  var type = MessageType.text;
  var status = MessageStatus.sent;
  var date = DateTime.now();

  MessageModel(this.id, this.message, this.type, this.status, this.date);
}
