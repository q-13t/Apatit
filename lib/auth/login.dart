import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginForm extends StatefulWidget {
  final Function setJWT;
  const LoginForm({super.key, required this.setJWT});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String username = '';
  String password = '';

  Future<void> login() async {
    log(username);
    log(password);
    // TODO: Implement Networking class
    // var url = Uri.http('192.168.43.233:8080', '/user/login');
    // var data = jsonEncode({'username': username, 'password': password});
    // var response = await http
    //     .post(url, body: data, headers: {'Content-Type': 'application/json'})
    //     .onError((error, stackTrace) {
    //       log(error.toString());
    //       return http.Response('Error', 500);
    //     });
    // log('Response status: ${response.statusCode}');
    // log('Response body: ${response.body}');
    // widget.setJWT(response.body);
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
                  child: ElevatedButton(onPressed: login, child: Text('Login')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
