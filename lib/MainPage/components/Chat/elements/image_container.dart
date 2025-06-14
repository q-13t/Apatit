import 'dart:io';

import 'package:flutter/material.dart';

class CustomImageContainer extends StatefulWidget {
  final File file;
  const CustomImageContainer({super.key, required this.file});

  @override
  State<CustomImageContainer> createState() => _CustomImageContainerState();
}

class _CustomImageContainerState extends State<CustomImageContainer> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Image(key: ValueKey<String>(widget.file.path), image: FileImage(widget.file));
  }
}
