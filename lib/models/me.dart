import 'dart:typed_data';

class Me {
  int id;
  String username;
  String? pfpUuid;
  Uint8List? pfp;

  Me(this.id, this.username, this.pfpUuid);

  factory Me.fromJson(Map<String, dynamic> json) {
    return Me(json['id'], json['username'], json['pfp_uuid']);
  }

  void setPfp(Uint8List pfp) => this.pfp = pfp;
}
