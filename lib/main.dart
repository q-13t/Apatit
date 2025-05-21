import 'dart:developer';

import 'package:apatite/MainPage/main_page_controller.dart';
import 'package:apatite/api/network_controller.dart';
import 'package:apatite/auth/auth_controller.dart';
import 'package:apatite/utils/toast_service.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkController.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
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
            log("JWT: ${NetworkController.jwtNotifier.value}");
            if (value == null) {
              return Center(child: CircularProgressIndicator());
            } else {
              return value.isEmpty ? AuthController() : MainPageController();
            }
          },
        ),
      ),
    );
  }
}
