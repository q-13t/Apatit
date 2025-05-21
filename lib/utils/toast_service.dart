import 'package:apatite/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();
  static late Logger _logger;
  factory ToastService() => _instance;

  ToastService._internal();

  void init(BuildContext context) {
    _logger = Logger("ToastServices");
    _context = context;
  }

  BuildContext? _context;

  void showToast(String message) {
    _logger.info("Toast: $message");
    if (_context != null) {
      toastification.show(primaryColor: Colors.white, foregroundColor: Colors.cyan, context: _context, title: Text(message), autoCloseDuration: const Duration(seconds: 5), backgroundColor: Colors.black87, style: ToastificationStyle.minimal);
    } else {
      throw Exception('Context is not initialized');
    }
  }
}
