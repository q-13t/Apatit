import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:Apatite/models/me.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:Apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NetworkController {
  static NetworkController _instance = NetworkController._();
  static bool _initialized = false;
  static String? token;
  static WebSocketChannel? _channel;
  static String baseUrlHttp = '192.168.137.1:8080';
  static String baseUrlWebSocket = 'ws://192.168.137.1:8081';
  NetworkController._();
  static final ValueNotifier<String?> jwtNotifier = ValueNotifier(null);
  static final messageStreamController = StreamController<String>.broadcast();
  static final Map<String, Uint8List?> _pfpCache = {};
  static late SharedPreferences _prefs;
  static late Logger _logger;

  static Me? _me = Me(-1, "User", -1);

  static Me? get me => _me;

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
    if (token != null && token != '') {
      bool valid = await NetworkController.askValidation(token);
      if (valid) {
        _getMe(token).then((meResp) => {_me = Me.fromJson(jsonDecode(meResp))});
        NetworkController.setToken(token);
      } else {
        NetworkController.setToken('');
      }
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
    if (token != null) {
      await _prefs.setString('token', token);
    }
    jwtNotifier.value = token;
    if (jwtIsEmpty()) {
      try {
        _channel!.sink.close();
      } catch (e) {
        _logger.err(e.toString());
      }
      _channel = null;
      return;
    }
    initWebSocket();
  }

  static void initWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse(baseUrlWebSocket));
    _channel!.stream.listen(
      (message) {
        messageStreamController.sink.add(message);
      },
      onError: (error) async {
        ToastService().showToast('Network error: $error');
        await _prefs.setString('token', jwtNotifier.value ?? '');
        await setToken(null);
      },
      onDone: () async {
        ToastService().showToast('No Connection To The Server');
        await _prefs.setString('token', jwtNotifier.value ?? '');
        await setToken(null);
      },
    );
  }

  void dispose() {
    _channel!.sink.close();
    messageStreamController.close();
  }

  static WebSocketChannel get channel {
    if (!_initialized) {
      setToken(null);
      throw Exception("WebSocket not initialized");
    }
    return _channel!;
  }

  NetworkController get instance => _instance;

  static Future<bool> login(String username, String password) async {
    var url = Uri.http(baseUrlHttp, '/user/login');
    _logger.debug("$url");
    var data = jsonEncode({'username': username, 'password': password});
    var response = await http.post(url, body: data, headers: {'Content-Type': 'application/json'}).onError((
      error,
      stackTrace,
    ) {
      //   _logger.err(error.toString());
      return http.Response('Error', 500);
    });
    if (response.statusCode != 200) {
      ToastService().showToast(response.body);
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
    var response = await http.post(url, body: data, headers: {'Content-Type': 'application/json'}).onError((
      error,
      stackTrace,
    ) {
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
    _channel!.sink.add(data);
  }

  static Future<String> _getMe(String token) async {
    var url = Uri.http(baseUrlHttp, '/user/getMe');
    var response = await http.get(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'});
    _logger.debug("Get me response: ${response.body}");
    return response.body;
  }

  static Future<bool> askValidation(String token) async {
    var url = Uri.http(baseUrlHttp, '/user/validateToken');
    var response = await http
        .post(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'})
        .onError((error, stackTrace) => http.Response('Error', 500));
    _logger.debug("Validation response: ${response.statusCode} - reason: ${response.body}");
    return response.statusCode == 200;
  }

  static void logout() {
    _me = Me(-1, "", -1);
    setToken('');
  }

  static Future<bool> uploadFile(File data, String uuid) async {
    var url = Uri.http(baseUrlHttp, '/file');
    var request = http.MultipartRequest('PUT', url);
    request.files.add(http.MultipartFile.fromBytes('file', data.readAsBytesSync(), filename: uuid));
    request.headers['Authorization'] = 'Bearer ${jwtNotifier.value}';
    var response = await request.send();
    _logger.debug("Upload file response: ${response.statusCode}");
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<Uint8List> getFile(String? fileUuid) {
    if (fileUuid == null) return Future.value(Uint8List(0));
    var url = Uri.http(baseUrlHttp, '/file', {'uuid': fileUuid});
    return http
        .get(url, headers: {'Content-Type': 'application/octet-stream', 'Authorization': 'Bearer ${jwtNotifier.value}'})
        .then((response) => response.bodyBytes);
  }
}
