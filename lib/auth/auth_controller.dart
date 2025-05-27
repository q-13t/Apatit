import 'package:Apatite/auth/login.dart';
import 'package:Apatite/auth/register.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = (_pageController.page! - index).abs();
                value = max(0, 1 - value); // Closer to 1 means more visible
              }
              return Transform.scale(
                scale: 0.95 + (0.05 * value), // Slight scale effect
                child: Opacity(opacity: value, child: child),
              );
            },
            child: index == 0 ? LoginForm() : RegisterForm(),
          );
        },
      ),
    );
  }
}
