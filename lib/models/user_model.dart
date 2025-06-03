import 'dart:typed_data';

class User {
  int id;
  String username;
  String? pfpUuid;
  Uint8List? pfp;

  User(this.id, this.username, this.pfpUuid);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(json['id'], json['username'], json['pfp_uuid']);
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, pfp_uuid: $pfpUuid}';
  }

  void setPfp(Uint8List pfp) => this.pfp = pfp;
}
