class UserTileModel {
  final String username;
  final int id;
  final int pfp;

  UserTileModel({required this.username, required this.id, required this.pfp});

  factory UserTileModel.fromMap(Map<String, dynamic> map) {
    return UserTileModel(username: map['username'], id: map['id'], pfp: map['pfp']);
  }
}
