import 'package:flutter/material.dart';
import 'dart:developer';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, required this.setJWT});
  final Function setJWT;

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  String username = '';
  String password = '';

  void login() {
    log(username);
    log(password);
    widget.setJWT('token');
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
              Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    child: Text('Register'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
