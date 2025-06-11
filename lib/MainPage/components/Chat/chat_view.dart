// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Apatite/MainPage/components/Chat/elements/message_tile.dart';
import 'package:Apatite/MainPage/components/empty_widget.dart';
import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/main.dart';
import 'package:Apatite/models/chat_tile_model.dart';
import 'package:Apatite/models/message_model.dart';
import 'package:Apatite/models/user_model.dart';
import 'package:Apatite/utils/enums.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:visibility_detector/visibility_detector.dart';

class ChatView extends StatefulWidget {
  final ChatTileModel model;
  static final Logger _logger = Logger("ChatView");

  const ChatView({super.key, required this.model});

  @override
  State<ChatView> createState() => ChatViewState();
}

class ChatViewState extends State<ChatView> {
  final _scrollController = ScrollController();

  late ValueNotifier<List<ValueNotifier<MessageModel>>> _messagesNotifiers;

  static final List<User> _participants = [];
  static List<User> get participants => _participants;

  String myInput = '';
  final _textController = TextEditingController();
  late StreamSubscription _subscription;
  File? _file;
  late MessageModel _mineCurrent;

  int offset = 0;
  int limit = 10;
  int lastLoad = 0;

  late ValueNotifier<bool> _displayScrollToBottom; //= ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _messagesNotifiers = ValueNotifier<List<ValueNotifier<MessageModel>>>([]);
    _mineCurrent = MessageModel(sender: NetworkController.me.id, chatId: widget.model.id);
    _displayScrollToBottom = ValueNotifier<bool>(false);

    NetworkController.getParticipants(widget.model.id).then((res) async {
      var jsonList = jsonDecode(res);
      ChatView._logger.debug("Participants: $jsonList");

      for (var u in jsonList) {
        if (u['id'] == NetworkController.me.id) {
          _participants.add(NetworkController.me);
        } else if (u['pfp_uuid'] != null) {
          var file = await NetworkController.getFile(u['pfp_uuid']);
          var user = User.fromJson(u);
          user.pfp = file?.readAsBytesSync();
          _participants.add(user);
        } else {
          _participants.add(User.fromJson(u));
        }
      }

      _subscription = NetworkController.messageStreamController.stream.listen((message) async {
        final data = jsonDecode(message.toString());
        final type = WSMType.values.firstWhere((e) => e.name == data['type'], orElse: () => WSMType.error);

        switch (type) {
          case WSMType.loadMessages:
            {
              final newList = List<MessageModel>.generate(data['messages'].length, (i) => MessageModel.fromJson(data['messages'][i]));
              final newNotifiers = newList.map((m) => ValueNotifier<MessageModel>(m));

              _messagesNotifiers.value.addAll(newNotifiers);
              lastLoad = newList.length;
              _messagesNotifiers.notifyListeners();
              break;
            }

          case WSMType.updateChat:
            {
              Timer(Duration(seconds: 5), () => setState(() {}));
              break;
            }
          case WSMType.addParticipant:
            {
              var innerData = jsonDecode(data['data']);
              var u = jsonDecode(innerData['user']);
              if (u['pfp_uuid'] != null) {
                var file = await NetworkController.getFile(u['pfp_uuid']);
                var user = User.fromJson(u);
                user.pfp = file?.readAsBytesSync();
                setState(() {
                  _participants.add(user);
                });
              } else {
                setState(() {
                  _participants.add(User.fromJson(u));
                });
              }
            }

          case WSMType.getMessages:
            {
              final newList = List<MessageModel>.generate(data['messages'].length, (i) => MessageModel.fromJson(data['messages'][i]));
              final newNotifiers = newList.map((m) => ValueNotifier<MessageModel>(m));

              _messagesNotifiers.value.insertAll(0, newNotifiers);
              lastLoad = newList.length;
              _messagesNotifiers.notifyListeners();
              break;
            }

          case WSMType.newMessage:
            {
              final incoming = MessageModel.fromJson(jsonDecode(data['data']));
              _messagesNotifiers.value.insert(0, ValueNotifier<MessageModel>(incoming));
              _messagesNotifiers.notifyListeners();
              break;
            }

          case WSMType.updateMessage:
            {
              final updated = MessageModel.fromJson(jsonDecode(data['data']));
              final targetNotifier = _messagesNotifiers.value.firstWhere((n) => n.value.id == updated.id, orElse: () => ValueNotifier<MessageModel>(updated));
              targetNotifier.value = targetNotifier.value.copyWith(status: updated.status);
              break;
            }

          case WSMType.sendMessage:
            {
              final sent = MessageModel.fromJson(jsonDecode(data['data']));
              _messagesNotifiers.value.insert(0, ValueNotifier<MessageModel>(sent));
              _messagesNotifiers.notifyListeners();
              break;
            }

          case WSMType.error:
            {
              ChatView._logger.err(data!.toString());
              break;
            }
          default:
            ChatView._logger.err("Unknown message type: ${data['type']}");
            break;
        }
      });

      NetworkController.websocketSend({'offset': offset, 'limit': limit, 'chat_id': widget.model.id}, WSMType.getMessages);

      _scrollController.addListener(_loadMoreMessages);
    });
  }

  void _loadMoreMessages() {
    if (_scrollController.position.pixels >= 100 && !_displayScrollToBottom.value) {
      _displayScrollToBottom.value = true;
    } else if (_scrollController.position.pixels <= 100 && _displayScrollToBottom.value) {
      _displayScrollToBottom.value = false;
    }
    if ((_scrollController.position.pixels >= (_scrollController.position.maxScrollExtent - 200)) && (lastLoad == limit)) {
      offset += limit;
      NetworkController.websocketSend({'offset': offset, 'limit': limit, 'chat_id': widget.model.id}, WSMType.loadMessages);
    }
  }

  String formatTimestamp() {
    final time = DateTime.now();
    return "${time.year}-"
        "${(time.month < 10) ? '0${time.month}' : time.month}-"
        "${(time.day < 10) ? '0${time.day}' : time.day} "
        "${(time.hour < 10) ? '0${time.hour}' : time.hour}:"
        "${(time.minute < 10) ? '0${time.minute}' : time.minute}:"
        "${(time.second < 10) ? '0${time.second}' : time.second}";
  }

  Future<bool> dispatchMessage() async {
    ChatView._logger.debug("Message: ${_mineCurrent.toDynamic()}");
    if (_mineCurrent.data != null) {
      final res = await NetworkController.uploadFile(_mineCurrent.data!, _mineCurrent.fileUuid!);
      if (res != 200) return false;
      NetworkController.websocketSend(_mineCurrent.toDynamic(), WSMType.sendMessage);
      return true;
    } else {
      NetworkController.websocketSend(_mineCurrent.toDynamic(), WSMType.sendMessage);
      return true;
    }
  }

  void sendMessage() async {
    ChatView._logger.debug("Messages: $myInput");
    if ((_mineCurrent.text == null || _mineCurrent.text!.isEmpty) && _mineCurrent.fileUuid == null) return;

    _mineCurrent.timeStamp = formatTimestamp();
    if (_mineCurrent.fileUuid == null) {
      _mineCurrent.type = MessageType.text;
    }
    _mineCurrent.status = MessageStatus.sent;

    await dispatchMessage();

    _mineCurrent = MessageModel(sender: NetworkController.me.id, chatId: widget.model.id);
    _textController.clear();
    clearFileSelection();
  }

  void addMyText(String text) {
    _mineCurrent.text = text;
  }

  void pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: false, compressionQuality: 30);
      if (result == null) return;

      _file = File(result.files.single.path!);
      if (_file == null) return;

      final extension = p.extension(_file!.path);
      final type = resolveMessageType(extension);
      final fileUuid = Main.getUuid();
      _mineCurrent.fileUuid = fileUuid + extension;
      _mineCurrent.type = type;
      _mineCurrent.data = await _file!.readAsBytes();
      setState(() {});
    } catch (e) {
      ChatView._logger.err(e.toString());
    }
  }

  MessageType resolveMessageType(String extension) {
    ChatView._logger.debug("Resolving extension: $extension");
    switch (extension) {
      case ".mp4":
      case ".mov":
      case ".mkv":
        return MessageType.video;
      case ".mp3":
      case ".wav":
        return MessageType.audio;
      case ".png":
      case ".jpg":
      case ".jpeg":
        return MessageType.image;
      default:
        return MessageType.file;
    }
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
    }
  }

  void clearFileSelection() {
    _mineCurrent.fileUuid = null;
    _mineCurrent.type = MessageType.text;
    setState(() {});
  }

  @override
  void dispose() {
    ChatView._logger.debug("Disposing chat view");
    for (var notifier in _messagesNotifiers.value) {
      notifier.dispose();
    }
    _messagesNotifiers.dispose();
    _subscription.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(tag: Main.getUuid(), child: CircleAvatar(child: ClipRRect(borderRadius: BorderRadius.circular(50), child: widget.model.pfp == null ? Icon(Icons.person) : Image.memory(widget.model.pfp!)))),
            SizedBox(width: 10),
            Text(widget.model.name),
          ],
        ),
        leading: IconButton(onPressed: () => Navigator.pop(context, (_) => {setState(() {})}), icon: const Icon(Icons.arrow_back)),

        actions: <Widget>[
          IconButton(onPressed: () => Navigator.pushNamed(context, '/chatSettings', arguments: {'model': widget.model}), icon: const Icon(Icons.settings)),
        ],
      ),
      backgroundColor: const Color.fromARGB(169, 68, 68, 68),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: ValueListenableBuilder<List<ValueNotifier<MessageModel>>>(
                    valueListenable: _messagesNotifiers,
                    builder: (context, notifiers, _) {
                      if (notifiers.isEmpty) {
                        return const WowSoEmpty();
                      }
                      return ListView.builder(
                        reverse: true,
                        controller: _scrollController,
                        itemCount: notifiers.length,
                        itemBuilder: (context, index) {
                          final messageNotifier = notifiers[index];
                          return ValueListenableBuilder<MessageModel>(
                            valueListenable: messageNotifier,
                            builder: (context, message, __) {
                              return VisibilityDetector(
                                key: ValueKey<int>(message.id ?? 0),
                                onVisibilityChanged: (info) {
                                  if (info.visibleFraction >= 0.5 && message.status == MessageStatus.delivered && message.sender != NetworkController.me.id) {
                                    final updated = message.copyWith(status: MessageStatus.seen);
                                    messageNotifier.value = updated;
                                    NetworkController.websocketSend(updated.toDynamic(), WSMType.updateMessage);
                                  }
                                },
                                child: MessageTile(key: ValueKey<int>(message.id ?? 0), message: message),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: _textController, decoration: const InputDecoration(hintText: 'Type a message', border: OutlineInputBorder()), onChanged: (value) => addMyText(value))),
                    IconButton(
                      icon: _mineCurrent.fileUuid == null ? const Icon(Icons.attach_file) : const Icon(Icons.clear),
                      style: ButtonStyle(shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))), backgroundColor: WidgetStateProperty.all(Colors.cyan[900])),
                      onPressed: () {
                        if (_mineCurrent.fileUuid == null) {
                          pickFile();
                        } else {
                          clearFileSelection();
                        }
                      },
                    ),
                    IconButton(
                      style: ButtonStyle(shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))), backgroundColor: WidgetStateProperty.all(Colors.cyan[900])),
                      icon: const Icon(Icons.send),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: _displayScrollToBottom,
            builder: (context, value, child) {
              return Visibility(visible: value, child: Positioned(bottom: 75, right: 20, child: FloatingActionButton(onPressed: scrollToBottom, child: const Icon(Icons.arrow_downward))));
            },
          ),
          // Positioned(bottom: 75, right: 20, child: _displayScrollToBottom ? FloatingActionButton(onPressed: scrollToBottom, child: const Icon(Icons.arrow_downward)) : Container()),
        ],
      ),
    );
  }
}
