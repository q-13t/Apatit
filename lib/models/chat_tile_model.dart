class ChatTileModel {
  final int id;
  final String name;
  final int pfp;

  ChatTileModel({required this.id, required this.name, required this.pfp});

  factory ChatTileModel.fromJson(Map<String, dynamic> json) {
    return ChatTileModel(id: json['id'], name: json['name'], pfp: json['pfp']);
  }
}
