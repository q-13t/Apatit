import 'dart:typed_data';

class Me {
  final int id;
  final String username;
  final int avatar;
  Uint8List? pfp;

  Me(this.id, this.username, this.avatar);

  factory Me.fromJson(Map<String, dynamic> json) => Me(json['id'], json['username'], json['pfp']);
}
