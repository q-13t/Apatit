import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String username;

  final int id;

  final int pfp;

  const UserTile({super.key, required this.username, required this.id, required this.pfp});

  @override
  Widget build(BuildContext context) {
    return Row(children: [CircleAvatar(), SizedBox(width: 10), Text(username, style: TextStyle(fontSize: 20))]);
  }
}
