import 'dart:io';

import 'package:Apatite/main.dart';
import 'package:Apatite/utils/toast_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileDownloader extends StatefulWidget {
  final File file;

  const FileDownloader({super.key, required this.file});

  @override
  State<FileDownloader> createState() => _FileDownloaderState();
}

class _FileDownloaderState extends State<FileDownloader> with AutomaticKeepAliveClientMixin {
  void handleFileSave() async {
    await FilePicker.platform
        .saveFile(dialogTitle: 'Save File To...', bytes: widget.file.readAsBytesSync(), fileName: widget.file.path.split('/').last)
        .then((val) => {if (val != null) ToastService.showToast("File Saved Successfully") else ToastService.showToast("Failed To Save File")})
        .catchError((e) => {ToastService.showToast("Failed To Save File")});
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FloatingActionButton.small(heroTag: Main.getUuid(), onPressed: handleFileSave, child: const Icon(Icons.download_outlined)),
        const SizedBox(width: 10),
        Expanded(child: Text(widget.file.path.split('/').last, style: const TextStyle(fontSize: 15, color: Colors.white), softWrap: true)),
      ],
    );
  }
}
