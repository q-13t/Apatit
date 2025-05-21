import 'package:apatite/api/network_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String username = '';
  String password = '';
  final secureStorage = FlutterSecureStorage();
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> login() async {
    NetworkController.login(username, password).then(
      (value) => {
        if (value) {storeCredentials()},
      },
    );
  }

  Future<void> storeCredentials() async {
    await secureStorage.write(key: 'username', value: username);
    await secureStorage.write(key: 'password', value: password);
  }

  Future<Map<String, String?>> getCredentials() async {
    final username = await secureStorage.read(key: 'username');
    final password = await secureStorage.read(key: 'password');
    return {'username': username, 'password': password};
  }

  Future<bool> authenticateWithBiometrics() async {
    final isAvailable = await auth.canCheckBiometrics;
    if (!isAvailable) return false;
    final didAuthenticate = await auth.authenticate(localizedReason: 'Please authenticate to continue', options: const AuthenticationOptions(biometricOnly: true));

    return didAuthenticate;
  }

  Future<void> handleBiometrics() async {
    final success = await authenticateWithBiometrics();
    if (success) {
      final credentials = await getCredentials();
      if (credentials['username'] != null && credentials['password'] != null) {
        // Use these to authenticate with backend
        await NetworkController.login(credentials['username']!, credentials['password']!);
      }
    }
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
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(hintText: 'Username', hintStyle: TextStyle(fontSize: 20)),
                onChanged:
                    (value) => setState(() {
                      username = value;
                    }),
              ),
              SizedBox(height: 16),
              TextField(
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(hintText: 'Password', hintStyle: TextStyle(fontSize: 20)),
                onChanged:
                    (value) => setState(() {
                      password = value;
                    }),
              ),
              Padding(padding: EdgeInsets.all(16), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: login, child: Text('Login', style: TextStyle(fontSize: 20))))),
              ElevatedButton(onPressed: () => {handleBiometrics()}, child: Icon(Icons.fingerprint, size: 30)),
            ],
          ),
        ),
      ),
    );
  }
}
