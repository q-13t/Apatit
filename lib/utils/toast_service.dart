import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();

  factory ToastService() => _instance;

  ToastService._internal();

  void init(BuildContext context) {
    _context = context;
  }

  BuildContext? _context;

  void showToast(String message) {
    log("Toast: $message");
    if (_context != null) {
      toastification.show(primaryColor: Colors.white, foregroundColor: Colors.cyan, context: _context, title: Text(message), autoCloseDuration: const Duration(seconds: 5), backgroundColor: Colors.black87, style: ToastificationStyle.minimal);
    } else {
      throw Exception('Context is not initialized');
    }
  }
}
