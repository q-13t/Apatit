import 'package:Apatite/MainPage/main_page_controller.dart';
import 'package:Apatite/api/network_controller.dart';
import 'package:Apatite/auth/auth_controller.dart';
import 'package:Apatite/utils/logger.dart';
import 'package:Apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkController.init();
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
            ToastService().init(context);
            log.debug("JWT: $value");
            if (value == null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => {NetworkController.init()},
                    child: Text("Retry", style: TextStyle(fontSize: 20)),
                  ),
                ],
              );
            } else {
              return value.isEmpty ? AuthController() : MainPageController();
            }
          },
        ),
      ),
    );
  }
}
