class ChatTileModel {
  int id;
  String name;
  String? pfp;
  String? lastMessage;

  ChatTileModel({required this.id, required this.name, this.pfp, this.lastMessage});

  factory ChatTileModel.fromJson(Map<String, dynamic> json) {
    return ChatTileModel(id: json['id'], name: json['name'], pfp: json['pfp'], lastMessage: json['lastMessage']);
  }
}
