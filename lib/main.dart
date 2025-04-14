import 'dart:developer';

import 'package:apatite/MainPage/main_page_controller.dart';
import 'package:apatite/auth/auth_controller.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String JWT = "yes";

  void setJWT(String token) {
    setState(() {
      JWT = token;
    });
    log(token);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white38,
          brightness: Brightness.dark,
        ),
      ),
      home:
          JWT.isNotEmpty
              ? MainPageController()
              : AuthController(setJWT: setJWT),
    );
  }
}
