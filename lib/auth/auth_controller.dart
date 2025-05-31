import 'package:Apatite/auth/login.dart';
import 'package:Apatite/auth/register.dart';
import 'package:flutter/material.dart';

class AuthController extends StatefulWidget {
  const AuthController({super.key});

  @override
  AuthControllerState createState() => AuthControllerState();
}

class AuthControllerState extends State<AuthController> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: 2,
        itemBuilder: (context, index) {
          return index == 0 ? LoginForm() : RegisterForm();
        },
      ),
    );
  }
}
