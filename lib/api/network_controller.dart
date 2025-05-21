import 'dart:async';
import 'dart:typed_data';

import 'package:apatite/utils/enums.dart';
import 'package:apatite/utils/logger.dart';
import 'package:apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NetworkController {
  static NetworkController _instance = NetworkController._();
  static bool _initialized = false;
  static String? token;
  static late WebSocketChannel _channel;
  static String baseUrlHttp = '192.168.1.157:8080';
  static String baseUrlWebSocket = 'ws://192.168.1.157:8081';
  NetworkController._();
  static final ValueNotifier<String?> jwtNotifier = ValueNotifier(null);
  static final messageStreamController = StreamController<String>.broadcast();
  static final Map<String, Uint8List?> _pfpCache = {};
  static late SharedPreferences _prefs;
  static late Logger _logger;

  static Uint8List? getCachedPFP(String username) => _pfpCache[username];

  static void setCachedPFP(String username, Uint8List? bytes) {
    _pfpCache[username] = bytes;
  }

  static bool jwtIsEmpty() => jwtNotifier.value == null || jwtNotifier.value == '';

  static Future<void> init() async {
    _logger = Logger("NetworkController");
    _logger.debug("Initializing Network Controller");
    _prefs = await SharedPreferences.getInstance();
    final token = _prefs.getString('token');
    if (token != null) {
      NetworkController.askValidation().then((value) => NetworkController.setToken(token));
    } else {
      NetworkController.setToken('');
    }
  }

  factory NetworkController() {
    if (!_initialized) {
      _instance = NetworkController._();
      NetworkController.init().then((value) => _initialized = true);
    }
    return _instance;
  }

  static Future<void> setToken(String? token) async {
    _prefs.setString('token', token ?? '');
    jwtNotifier.value = token;
    if (token != null) {
      _channel = WebSocketChannel.connect(Uri.parse(baseUrlWebSocket));
      _channel.stream.listen(
        (message) {
          messageStreamController.sink.add(message);
        },
        onError: (error) async {
          ToastService().showToast('Network error: $error');
          await setToken(null);
        },
        onDone: () async {
          ToastService().showToast('No Connection To The Server');
          await setToken(null);
        },
      );
    }
  }

  void dispose() {
    _channel.sink.close();
    messageStreamController.close();
  }

  static WebSocketChannel get channel {
    if (!_initialized) {
      setToken(null);
      throw Exception("WebSocket not initialized");
    }
    return _channel;
  }

  NetworkController get instance => _instance;

  static Future<bool> login(String username, String password) async {
    var url = Uri.http(baseUrlHttp, '/user/login');
    var data = jsonEncode({'username': username, 'password': password});
    var response = await http.post(url, body: data, headers: {'Content-Type': 'application/json'}).onError((error, stackTrace) {
      return http.Response('Error', 500);
    });
    if (response.statusCode != 200) {
      ToastService().showToast(jsonDecode(response.body)['error']);
      return false;
    }
    await setToken(jsonDecode(response.body)['token']);
    if (jwtNotifier.value == '') {
      return false;
    }
    return true;
  }

  static Future<bool> register(String username, String password) async {
    var url = Uri.http(baseUrlHttp, '/user/register');
    var data = jsonEncode({'username': username, 'password': password});
    var response = await http.post(url, body: data, headers: {'Content-Type': 'application/json'}).onError((error, stackTrace) {
      return http.Response('Error', 500);
    });
    if (response.statusCode != 200) {
      ToastService().showToast(jsonDecode(response.body)['error']);
      return false;
    }
    await setToken(jsonDecode(response.body)['token']);
    if (jwtNotifier.value == '') {
      return false;
    }
    return true;
  }

  static void websocketSend(Map<String, dynamic> message, WSMType type) async {
    if (jwtNotifier.value == null || jwtNotifier.value == '') {
      ToastService().showToast('WebSocket not initialized');
      setToken(null);
      return;
    }
    var data = jsonEncode({'token': jwtNotifier.value, 'type': WSMTWrapper[type].toString(), 'data': message});
    _logger.debug("WS sending: $data");
    _channel.sink.add(data);
  }

  static Future<bool> askValidation() async {
    var url = Uri.http(baseUrlHttp, '/user/validateToken');
    var response = await http.post(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${jwtNotifier.value}'});
    return response.statusCode == 200;
  }
}
