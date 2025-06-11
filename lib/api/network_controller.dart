// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:Apatite/models/user_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:Apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:path_provider/path_provider.dart';

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
  static late Directory tempDir;

  static BuildContext? mainContext;

  static User _me = User(-1, "", "");
  static User get me => _me;
  static Uint8List? getCachedPFP(String username) => _pfpCache[username];

  static void setCachedPFP(String username, Uint8List? bytes) {
    _pfpCache[username] = bytes;
  }

  static bool jwtIsEmpty() => jwtNotifier.value == null || jwtNotifier.value == '';

  Future<void> init(int timeout) async {
    while (true) {
      if (await ping(timeout)) {
        _logger.debug("Initializing Network Controller");
        tempDir = await getTemporaryDirectory();
        _prefs = await SharedPreferences.getInstance();
        final token = _prefs.getString('token');
        if (token != null && token != '' && token.isNotEmpty) {
          bool valid = await askValidation(token);
          if (valid) {
            await setToken(token);
          } else {
            ToastService.showToast('Invalid Token');
            await setToken('');
          }
        } else {
          ToastService.showToast('Invalid Token');
          await setToken('');
        }
        break;
      }
      await Future.delayed(Duration(seconds: timeout + 5));
    }
  }

  static Future<bool> ping(int timeout) async {
    _logger.debug("Pinging server");
    final response = await http.get(Uri.http(baseUrlHttp, '/ping')).timeout(Duration(seconds: timeout), onTimeout: () => http.Response("Unreachable", 523)).catchError((e) => http.Response(e.toString(), 523));
    if (response.statusCode == 200) {
      _logger.info("Pinged server");
      return true;
    } else {
      _logger.info("Failed to ping server, response: ${response.body}");
      return false;
    }
  }

  factory NetworkController(context, int timeout) {
    if (!_initialized) {
      _instance = NetworkController._();
      _logger = Logger("NetworkController");
      _instance.init(timeout);
      _initialized = true;
      mainContext = context;
    } else if (token == null || token == '') {
      _instance.init(timeout);
    }
    return _instance;
  }

  static Future<void> setToken(String? token) async {
    jwtNotifier.value = token;
    if (token != null && token.isNotEmpty) {
      _prefs.setString('token', token);
      initWebSocket();
      _getMe(token).then((meResp) {
        _me = User.fromJson(jsonDecode(meResp));
        websocketSend({"id": _me.id}, WSMType.bind);
        getFile(_me.pfpUuid).then((value) => _me.pfp = value?.readAsBytesSync());
      });
    } else {
      // _prefs.remove('token');
      _channel?.sink.close();
      _channel = null;
    }
  }

  static void initWebSocket() {
    _channel = WebSocketChannel.connect(Uri.parse(baseUrlWebSocket));
    _channel!.stream.listen(
      (message) {
        messageStreamController.sink.add(message);
      },
      onError: (error) async {
        ToastService.showToast('Network error: $error');
        Navigator.popUntil(mainContext!, ModalRoute.withName('/'));
        await _prefs.setString('token', jwtNotifier.value ?? '');
        await setToken(null);
      },
      onDone: () async {
        ToastService.showToast('No Connection To The Server');
        Navigator.popUntil(mainContext!, ModalRoute.withName('/'));
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

  static Future<bool> login(String? username, String? password) async {
    var url = Uri.http(baseUrlHttp, '/user/login');
    _logger.debug("$url");
    var data = jsonEncode({'username': username, 'password': password});
    var response = await http.post(url, body: data, headers: {'Content-Type': 'application/json'}).onError((error, stackTrace) {
      //   _logger.err(error.toString());
      return http.Response('Error', 500);
    });
    if (response.statusCode != 200) {
      ToastService.showToast(response.body);
      return false;
    }
    await setToken(jsonDecode(response.body)['token']);
    return jwtNotifier.value != null && jwtNotifier.value != '';
  }

  static Future<bool> register(String username, String password) async {
    var url = Uri.http(baseUrlHttp, '/user/register');
    var data = jsonEncode({'username': username, 'password': password});
    var response = await http.post(url, body: data, headers: {'Content-Type': 'application/json'}).onError((error, stackTrace) {
      return http.Response('Error', 500);
    });
    if (response.statusCode != 200) {
      ToastService.showToast(jsonDecode(response.body)['error']);
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
      ToastService.showToast('WebSocket not initialized');
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
    if (response.statusCode == 401) {
      ToastService.showToast('Unauthorized');
      final secureStorage = FlutterSecureStorage();
      NetworkController.login(await secureStorage.read(key: 'username'), await secureStorage.read(key: 'password'));
    }
    return response.body;
  }

  static Future<bool> askValidation(String token) async {
    var url = Uri.http(baseUrlHttp, '/user/validateToken');
    var response = await http.post(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}).timeout(Duration(seconds: 50)).onError((error, stackTrace) {
      setToken(null);
      return http.Response('Error', 500);
    });
    _logger.debug("Validation response: ${response.statusCode} - reason: ${response.body}");
    return response.statusCode == 200;
  }

  static void logout() {
    _me = User(-1, "", "");
    tempDir.delete(recursive: true);
    setToken('');
  }

  static Future<int> uploadFile(Uint8List data, String uuid) async {
    var url = Uri.http(baseUrlHttp, '/file');
    var request = http.MultipartRequest('PUT', url);
    request.files.add(http.MultipartFile.fromBytes('file', data, filename: uuid));
    request.headers['Authorization'] = 'Bearer ${jwtNotifier.value}';
    var response = await request.send();
    _logger.debug("Upload file response: ${response.statusCode}");
    if (response.statusCode == 200) {
      var file = File('${tempDir.path}/$uuid');
      await file.writeAsBytes(data);
    }
    if (response.statusCode == 401) {
      ToastService.showToast('Unauthorized');
      final secureStorage = FlutterSecureStorage();
      NetworkController.login(await secureStorage.read(key: 'username'), await secureStorage.read(key: 'password'));
    }
    return response.statusCode;
  }

  static Future<File?> getFile(String? fileUuid) async {
    if (fileUuid == null) return null;
    final file = File('${tempDir.path}/$fileUuid');

    if (await file.exists()) {
      return file;
    } else {
      var url = Uri.http(baseUrlHttp, '/file', {'uuid': fileUuid});
      return http.get(url, headers: {'Content-Type': 'application/octet-stream', 'Authorization': 'Bearer ${jwtNotifier.value}'}).then((response) async {
        if (response.statusCode == 200) {
          return await file.writeAsBytes(response.bodyBytes);
        } else {
          return null;
        }
      });
    }
  }

  static Future<int> updateUsername(String newUserName) async {
    var url = Uri.http(baseUrlHttp, '/user/changeUsername');
    var data = jsonEncode({"username": me.username, "newUsername": newUserName});
    var response = await http.patch(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${jwtNotifier.value}'}, body: data).onError((error, stackTrace) => http.Response('Error', 500));
    _logger.debug("updateUsername response: ${response.statusCode} - reason: ${response.body}");
    if (response.statusCode == 401) {
      ToastService.showToast('Unauthorized');
      final secureStorage = FlutterSecureStorage();
      NetworkController.login(await secureStorage.read(key: 'username'), await secureStorage.read(key: 'password'));
    } else if (response.statusCode == 200) {
      _me.username = newUserName;
      final secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: 'username', value: newUserName);
    }
    return response.statusCode;
  }

  static Future<int> updatePassword(String newPassword, String oldPassword) async {
    var url = Uri.http(baseUrlHttp, '/user/changePassword');
    var data = jsonEncode({"username": me.username, "old_password": oldPassword, "new_password": newPassword});
    var response = await http.patch(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${jwtNotifier.value}'}, body: data).onError((error, stackTrace) => http.Response('Error', 500));
    _logger.debug("updatePassword response: ${response.statusCode} - reason: ${response.body}");
    if (response.statusCode == 401) {
      ToastService.showToast('Unauthorized');
      final secureStorage = FlutterSecureStorage();
      NetworkController.login(await secureStorage.read(key: 'username'), await secureStorage.read(key: 'password'));
    } else if (response.statusCode == 200) {
      final secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: 'password', value: newPassword);
    }
    return response.statusCode;
  }

  static Future<int> updatePFP(String fileName, File? newPfp) async {
    var url = Uri.http(baseUrlHttp, '/user/changePfp');
    var data = jsonEncode({"username": me.username, "pfp": fileName});
    var response = await http.patch(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${jwtNotifier.value}'}, body: data).onError((error, stackTrace) => http.Response('Error', 500));
    if (response.statusCode == 401) {
      ToastService.showToast('Unauthorized');
      final secureStorage = FlutterSecureStorage();
      NetworkController.login(await secureStorage.read(key: 'username'), await secureStorage.read(key: 'password'));
    } else if (response.statusCode == 200) {
      _logger.err("updatePassword response: ${response.statusCode} - reason: ${response.body}");
      _me.pfpUuid = fileName;
      if (newPfp != null) _me.setPfp(newPfp.readAsBytesSync());
    }
    return response.statusCode;
  }

  static Future<String> getParticipants(int id) async {
    var url = Uri.http(baseUrlHttp, '/chat/participants', {'id': id.toString()});
    return await http.get(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${jwtNotifier.value}'}).then((response) => response.body);
  }

  static Future<bool> changeChatName(int chat_id, String name) async {
    var url = Uri.http(baseUrlHttp, '/chat/changeName');
    var data = jsonEncode({"chat_id": chat_id, "chat_name": name});
    var response = await http.patch(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${jwtNotifier.value}'}, body: data).catchError((e) => http.Response('Error', 500));
    return response.statusCode == 200;
  }

  static Future<bool> changeChatPfp(int chat_id, String pfp_uuid) async {
    var url = Uri.http(baseUrlHttp, '/chat/changePfp');
    var data = jsonEncode({"chat_id": chat_id, "pfp_uuid": pfp_uuid});
    var response = await http.patch(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${jwtNotifier.value}'}, body: data).catchError((e) => http.Response('Error', 500));
    return response.statusCode == 200;
  }

  static Future<bool> addParticipantToChat(int chat_id, int user_id) async {
    var url = Uri.http(baseUrlHttp, '/chat/addParticipant');
    var data = jsonEncode({"chat_id": chat_id, "user_id": user_id});
    var response = await http.patch(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${jwtNotifier.value}'}, body: data).catchError((e) => http.Response('Error', 500));
    return response.statusCode == 200;
  }

  static Future<bool> removeParticipantFromChat(int chat_id, int user_id) async {
    var url = Uri.http(baseUrlHttp, '/chat/removeParticipant');
    var data = jsonEncode({"chat_id": chat_id, "user_id": user_id});
    var response = await http.patch(url, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${jwtNotifier.value}'}, body: data).catchError((e) => http.Response('Error', 500));
    return response.statusCode == 200;
  }
}
