// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'home_page.dart';

class AuthData {
  final String email;
  final String password;
  final String name;

  AuthData({
    required this.email,
    required this.password,
    required this.name,
  });

  static Future<void> login(String email) async {
    // TODO: Implement login logic
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _register() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      final authData = AuthData(
        email: emailController.text,
        password: passwordController.text,
        name:
            emailController.text.split('@')[0], // Using email username as name
      );
      AuthData.login(authData.email);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Créer un compte',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', fillColor: Colors.white, filled: true),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    fillColor: Colors.white,
                    filled: true),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: _register, child: const Text('S\'inscrire')),
            ],
          ),
        ),
      ),
    );
  }
}
