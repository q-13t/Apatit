class UserTileModel {
  final int id;
  final String username;
  final String? pfp_uuid;

  UserTileModel({required this.username, required this.id, required this.pfp_uuid});

  factory UserTileModel.fromMap(Map<String, dynamic> map) {
    return UserTileModel(username: map['username'], id: map['id'], pfp_uuid: map['pfp_uuid']);
  }
}
