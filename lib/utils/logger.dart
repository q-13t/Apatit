import 'dart:developer';

class Logger {
  late String _clazz = "Unknown";
  static int _level = 1;
  static int _maxClazzName = 0;

  static void setLevel(int l) {
    _level = l;
  }

  Logger(String? clazz) {
    // If clazz is null, Name Will be Unknown
    if (clazz == null) return;
    _maxClazzName = (_clazz.length > _maxClazzName) ? _clazz.length : _maxClazzName;
    // LeftPad with spaces
    if (_clazz.length < _maxClazzName) {
      _clazz = ' ' * (_maxClazzName - _clazz.length) + _clazz;
    }
    _clazz = clazz;
  }

  void info(String message) {
    if (_level > 2) {
      log('${DateTime.now()} - INFO - [$_clazz]: $message');
    }
  }

  void debug(String message) {
    if (_level > 1) {
      log('${DateTime.now()} - DEBUG - [$_clazz]: $message');
    }
  }

  void err(String message) {
    if (_level > 0) {
      log('${DateTime.now()} - ERROR - [$_clazz]: $message');
    }
  }
}
