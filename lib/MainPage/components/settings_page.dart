import 'dart:io';
import 'dart:typed_data';

import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/main.dart';
import 'package:Apatite/utils/logger.dart' show Logger;
import 'package:Apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _newUserName = NetworkController.me.username.isEmpty ? 'Apatite' : NetworkController.me.username;
  String _newPassword = '';
  String _oldPassword = '';
  File? _newPfp;
  // ignore: unused_field
  final Logger _logger = Logger("SettingsPageState");
  Uint8List? _oldPfp = NetworkController.me.pfp;
  String newUUID = Main.getUuid();

  final picker = ImagePicker();
  final cropper = ImageCropper();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> updateUserData() async {
    if (_newUserName != '' && _newUserName != NetworkController.me.username) {
      await NetworkController.updateUsername(_newUserName).then((status) {
        if (status == 200) {
          ToastService.showToast('Username updated');
        } else {
          ToastService.showToast('Something went wrong');
        }
      });
    }

    if (_newPassword.isNotEmpty || _newPassword.isNotEmpty) {
      if (_oldPassword != _newPassword) {
        ToastService.showToast('New password must be different from the old one');
        return;
      }
      NetworkController.updatePassword(_newPassword, _oldPassword).then((status) {
        if (status == 200) {
          ToastService.showToast('Password updated');
        } else {
          ToastService.showToast('Something went wrong');
        }
      });
    }

    if (_newPfp != null) {
      var newFileName = newUUID + p.extension(_newPfp!.path);
      NetworkController.uploadFile(_newPfp!.readAsBytesSync(), newFileName).then((code) {
        if (code == 200) {
          NetworkController.updatePFP(newFileName, _newPfp).then((status) {
            if (status == 200) {
              ToastService.showToast('Profile picture updated');
              NetworkController.me.pfp = _newPfp!.readAsBytesSync();
              NetworkController.me.pfpUuid = newFileName;
              _newPfp = null;
              newUUID = Main.getUuid();
            } else {
              ToastService.showToast('Something went wrong');
            }
          });
        }
      });
    }
  }

  Widget buildImage() {
    _logger.debug("Image Stored: ${NetworkController.me.pfpUuid} ");
    if (_newPfp != null) {
      return CircleAvatar(child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.file(_newPfp!)));
    } else if (_oldPfp != null) {
      return CircleAvatar(child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.memory(_oldPfp!)));
    } else if (_oldPfp == null && NetworkController.me.pfpUuid != null) {
      return FutureBuilder(
        future: NetworkController.getFile(NetworkController.me.pfpUuid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Uint8List? data = snapshot.data?.readAsBytesSync();
            _oldPfp = data;
            NetworkController.me.pfp = data;
            return CircleAvatar(child: ClipRRect(borderRadius: BorderRadius.circular(100), child: Image.memory(data!)));
          } else {
            return CircleAvatar(child: Icon(Icons.person));
          }
        },
      );
    } else {
      return CircleAvatar(child: Icon(Icons.person));
    }
  }

  clearCache() {
    NetworkController.tempDir.delete(recursive: true).then((value) => ToastService.showToast('Cache cleared')).catchError((e) {
      ToastService.showToast(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width,
                    child: GestureDetector(
                      onTap: () async {
                        final pickedFile = await picker.pickImage(source: ImageSource.gallery, preferredCameraDevice: CameraDevice.front);
                        if (pickedFile == null) {
                          return;
                        }

                        final cropped = await cropper.cropImage(
                          compressFormat: ImageCompressFormat.jpg,
                          compressQuality: 40,
                          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                          uiSettings: [
                            AndroidUiSettings(toolbarTitle: 'Crop Image', backgroundColor: Color.fromARGB(169, 0, 0, 0), toolbarWidgetColor: Colors.black, cropStyle: CropStyle.circle, initAspectRatio: CropAspectRatioPreset.original, lockAspectRatio: false),
                          ],
                          sourcePath: pickedFile.path,
                        );

                        _newPfp = File(cropped!.path);
                        setState(() {});
                      },
                      child: buildImage(),
                    ),
                  ),
                  TextField(decoration: InputDecoration(hintText: 'Enter Username', border: OutlineInputBorder()), onChanged: (value) => {_newUserName = value}),
                  TextField(decoration: InputDecoration(hintText: 'Enter New Password', border: OutlineInputBorder()), onChanged: (value) => {_newPassword = value}),
                  TextField(decoration: InputDecoration(hintText: 'Enter Old Password', border: OutlineInputBorder()), onChanged: (value) => {_oldPassword = value}),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => {clearCache()},
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.redAccent[200]), iconColor: WidgetStateProperty.all(Colors.black), shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                child: Column(children: [Icon(Icons.delete_forever), Text('Clear Cache')]),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => {updateUserData()},
                style: ButtonStyle(shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), minimumSize: WidgetStateProperty.all(Size(60, 60))),
                child: Icon(Icons.save, size: 40),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
