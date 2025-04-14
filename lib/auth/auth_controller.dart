import 'package:apatite/auth/login.dart';
import 'package:apatite/auth/register.dart';
import 'package:flutter/material.dart';

class AuthController extends StatefulWidget {
  final Function setJWT;

  const AuthController({super.key, required this.setJWT});

  @override
  _AuthControllerState createState() => _AuthControllerState();
}

enum AuthType { login, register }

class _AuthControllerState extends State<AuthController> {
  AuthType authType = AuthType.login;

  void changePane(AuthType type) {
    setState(() {
      authType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return Placeholder();
    return Scaffold(
      body:
          authType == AuthType.login
              ? LoginForm(setJWT: widget.setJWT)
              : RegisterForm(setJWT: widget.setJWT),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => changePane(AuthType.login),
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () => changePane(AuthType.register),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
