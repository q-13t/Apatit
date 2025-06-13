import 'dart:io';

import 'package:Apatite/utils/toast_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileDownloader extends StatelessWidget {
  final File file;

  const FileDownloader({super.key, required this.file});

  void handleFileSave() async {
    await FilePicker.platform
        .saveFile(dialogTitle: 'Save File To...', bytes: file.readAsBytesSync(), fileName: file.path.split('/').last)
        .then((val) => {if (val != null) ToastService.showToast("File Saved Successfully") else ToastService.showToast("Failed To Save File")})
        .catchError((e) => {ToastService.showToast("Failed To Save File")});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FloatingActionButton.small(onPressed: handleFileSave, child: const Icon(Icons.download_outlined)),
        const SizedBox(width: 10),
        Expanded(child: Text(file.path.split('/').last, style: const TextStyle(fontSize: 15, color: Colors.white), softWrap: true)),
      ],
    );
  }
}
