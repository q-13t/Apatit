import 'dart:math';

import 'package:Apatite/MainPage/components/Chat/chat_settings.dart';
import 'package:Apatite/MainPage/components/Chat/chat_view.dart';
import 'package:Apatite/MainPage/components/new_chat/new_chat_controller.dart';
import 'package:Apatite/MainPage/main_page_controller.dart';
import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/auth/auth_controller.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:Apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ThemeContext());
}

class ThemeContext extends StatelessWidget {
  const ThemeContext({super.key});
  Route<dynamic>? __onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    switch (settings.name) {
      case '/newChat':
        return MaterialPageRoute(builder: (context) => NewChatController(model: args?['model']));
      case '/chat':
        return MaterialPageRoute(builder: (context) => ChatView(model: args?['model']));
      case '/chatSettings':
        return MaterialPageRoute(builder: (context) => ChatSettings(model: args?['model']));
      case '/':
        return MaterialPageRoute(builder: (context) => build(context));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Apatite', debugShowCheckedModeBanner: false, theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.white38, brightness: Brightness.dark)), onGenerateRoute: __onGenerateRoute, home: MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => Main();
}

class Main extends State<MyApp> {
  final Logger log = Logger("Main");
  static const uuid = Uuid();
  String timer = "0";

  final random = Random();
  static String getUuid() => uuid.v4();

  List<String> uniqueEmojis = [
    // Smileys & People
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘', '😗', '😙', '😚',
    '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏', '😒', '😞', '😔', '😟', '😕', '🙁', '☹️',
    '😣', '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠', '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨', '😰', '😥', '😓',
    '🤗', '🤔', '🤭', '🤫', '🤥', '😶', '😐', '😑', '😬', '🙄', '😯', '😦', '😧', '😮', '😲', '🥱',
    '😴', '🤤', '😪', '😵', '😵', '🤐', '🥴', '🤢', '🤮', '🤧', '😷', '🤒', '🤕', '🤑', '🤠', '😈', '👿', '👹', '👺', '💀',
    '☠️', '👻', '👽', '👾', '🤖', '😺', '😸', '😹', '😻', '😼', '😽', '🙀', '😿', '😾',

    // People & Body
    '👶', '🧒', '👦', '👧', '🧑', '👱', '👨', '👩', '🧓', '👴', '👵', '🙍', '🙎', '🙅', '🙆', '💁', '🙋', '🧏', '🙇', '🤦', '🤷',

    // Animals & Nature
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🦁', '🐯', '🐮', '🐷', '🐽', '🐸', '🐵', '🙈', '🙉', '🙊', '🐒', '🐔', '🐧',
    '🐦', '🐤', '🐣', '🐥', '🦆', '🦅', '🦉', '🦇', '🐺', '🐗', '🐴', '🦄', '🐝', '🐛', '🦋', '🐌', '🐞', '🐜', '🦟', '🦗', '🕷️', '🦂',

    // Food & Drink
    '🍏', '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🍈', '🍒', '🍑', '🥭', '🍍', '🥥', '🥝', '🍅', '🍆', '🥑', '🥦',
    '🥬', '🥒', '🌶️', '🌽', '🥕', '🧄', '🧅', '🥔', '🍠', '🥐', '🥯', '🍞', '🥖', '🥨', '🧀', '🥚', '🍳', '🧈',
    '🥞', '🧇', '🥓', '🥩', '🍗', '🍖', '🦴', '🌭', '🍔', '🍟', '🍕', '🥪', '🥙', '🧆', '🌮', '🌯', '🥗', '🥘', '🍝',
    '🍜', '🍲', '🍛', '🍣', '🍱', '🥟', '🦪', '🍤', '🍙', '🍚', '🍘', '🍥', '🥠', '🥮', '🍢', '🍡', '🍧', '🍨', '🍦', '🥧', '🧁',
    '🍰', '🎂', '🍮', '🍭', '🍬', '🍫', '🍿', '🧃', '🥤', '🧉', '🍵', '☕', '🥛', '🍼', '🍺', '🍻', '🥂', '🍷', '🥃', '🍸',

    // Travel & Places
    '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑', '🚒', '🚐', '🚚', '🚛', '🚜', '🛺', '🚲', '🛴', '🛵', '🏍️', '🛶', '⛵', '🛳️', '🚢', '✈️', '🚁', '🚀',

    // Objects
    '⌚', '📱', '📲', '💻', '⌨️', '🖥️', '🖨️', '🖱️', '🖲️', '💽', '💾', '💿', '📀', '📼', '📷', '📸', '📹', '🎥', '📽️', '🎞️', '📞', '☎️',
    '📟', '📠', '📺', '📻', '🎙️', '🎚️', '🎛️', '🧭', '⏱️', '⏲️', '⏰', '🕰️', '🔋', '🔌', '💡', '🔦', '🕯️', '🪔', '🧯', '🛢️', '💸',

    // Symbols
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔', '❣️', '💕', '💞', '💓', '💗', '💖', '💘', '💝', '💟', '☮️', '✝️', '☪️', '🕉️', '☸️', '✡️',
    '🔯', '🕎', '☯️', '☦️', '🛐', '⛎', '♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓', '🆔', '⚛️', '🉑', '☢️', '☣️', '📴', '📳',
  ];

  String emojis = '';
  int timeout = 10;

  @override
  void initState() {
    super.initState();
    Logger.setLevel(2);
    NetworkController(navigatorCallback).init(timeout, timerCallback);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void navigatorCallback() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  void timerCallback(String update) {
    setState(() {
      timer = update;

      if (int.parse(timer) - 1 == 0) {
        emojis = '';
      }
      emojis += uniqueEmojis[Random().nextInt(uniqueEmojis.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ValueListenableBuilder(
        valueListenable: NetworkController.jwtNotifier,
        builder: (context, value, child) {
          ToastService.init(context);
          if (value == null) {
            return Scaffold(
              body: Center(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(key: const Key('progressIndicator')),
                      SizedBox(height: 20),
                      Text("Reaching for server", style: TextStyle(fontSize: 20, color: Colors.white)),
                      SizedBox(height: 20),
                      Text(timer, style: TextStyle(fontSize: 20, color: Colors.white)),
                      SizedBox(height: 20),
                      Text(emojis, style: TextStyle(fontSize: 20, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            );
          }

          return value.isEmpty ? const AuthController() : const MainPageController();
        },
      ),
    );
  }
}
