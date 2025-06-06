import 'package:Apatite/MainPage/main_page_controller.dart';
import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/auth/auth_controller.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:Apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // NetworkController();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => Main();
}

class Main extends State<MyApp> {
  late Logger log;
  static const uuid = Uuid();

  static String getUuid() => uuid.v4();

  @override
  void initState() {
    super.initState();
    log = Logger("MyApp");
    Logger.setLevel(2);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apatite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.white38, brightness: Brightness.dark)),
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: ValueListenableBuilder(
          valueListenable: NetworkController.jwtNotifier,
          builder: (context, value, child) {
            ToastService.init(context);
            log.debug("JWT: $value");
            if (value == null) {
              NetworkController();
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            return value.isEmpty ? const AuthController() : const MainPageController();
          },
        ),
      ),
    );
  }
}
