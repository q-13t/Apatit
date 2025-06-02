import 'dart:typed_data';

class User {
  int id;
  String username;
  String? pfpUuid;
  Uint8List? pfp;

  User(this.id, this.username, this.pfpUuid);

  factory User.fromJson(Map<String, dynamic> json) {
    return User(json['id'], json['username'], json['pfpUUID']);
  }

  void setPfp(Uint8List pfp) => this.pfp = pfp;
}
