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
    _maxClazzName = clazz.length > _maxClazzName ? clazz.length : _maxClazzName;
    _clazz = clazz;
  }

  void debug(String? message) {
    if (_level >= 2) {
      if (_clazz.length < _maxClazzName) {
        _clazz = _clazz.padLeft(_maxClazzName);
      }
      log('${DateTime.now()} - DEBUG - [$_clazz]:\n $message');
    }
  }

  void info(String? message) {
    if (_level >= 1) {
      if (_clazz.length < _maxClazzName) {
        _clazz = _clazz.padLeft(_maxClazzName);
      }
      log('${DateTime.now()} - INFO  - [$_clazz]:\n $message');
    }
  }

  void err(String? message) {
    if (_level >= 0) {
      if (_clazz.length < _maxClazzName) {
        _clazz = _clazz.padLeft(_maxClazzName);
      }
      log('${DateTime.now()} - ERROR - [$_clazz]:\n $message');
    }
  }
}
