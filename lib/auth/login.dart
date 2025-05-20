import 'dart:developer';

import 'package:apatite/api/network_controller.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String username = '';
  String password = '';

  Future<void> login() async {
    NetworkController.login(username, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: 'Username'),
                onChanged:
                    (value) => setState(() {
                      username = value;
                    }),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(hintText: 'Password'),
                onChanged:
                    (value) => setState(() {
                      password = value;
                    }),
              ),
              Padding(padding: EdgeInsets.all(16), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: login, child: Text('Login')))),
            ],
          ),
        ),
      ),
    );
  }
}
