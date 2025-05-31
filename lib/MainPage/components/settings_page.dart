import 'dart:io';

import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _newUserName = '';
  String _newPassword = '';
  File? _newPfp;

  void updateUserData() {
    if (_newPfp == null) return;
    NetworkController.uploadFile(_newPfp!, Main.getUuid());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onTap: () async {
                FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(allowMultiple: false);
                if (pickedFile == null) {
                  return;
                }
                _newPfp = File(pickedFile.files.single.path!);
                setState(() {});
              },

              child: CircleAvatar(
                radius: 50,
                backgroundImage: _newPfp == null ? null : FileImage(_newPfp!),
                child: _newPfp == null ? Icon(Icons.person, size: 50) : null,
              ),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            decoration: InputDecoration(hintText: 'Enter Username', border: OutlineInputBorder()),
            onChanged: (value) => {_newUserName = value},
          ),
          TextField(
            decoration: InputDecoration(hintText: 'Enter Password', border: OutlineInputBorder()),
            onChanged: (value) => {_newPassword = value},
          ),
          Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => {},
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.redAccent[200]),
                    iconColor: WidgetStateProperty.all(Colors.black),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  child: Icon(Icons.delete_forever),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => {updateUserData()},
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    minimumSize: WidgetStateProperty.all(Size(60, 60)),
                  ),
                  child: Icon(Icons.save, size: 40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
