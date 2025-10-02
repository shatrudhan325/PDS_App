import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool loading = false;
  void login() async {
    setState(() {
      loading = true;
    });
    try {
      print("In try");
      final response = await http
          .post(
            Uri.parse('https://dummyjson.com/auth/login'),
            body: jsonEncode({
              'username': usernameController.text,
              'password': passwordController.text,
            }),
          )
          .then((response) {
            if (response.statusCode == 200) {
              print('Login successful: ${response.body}');
            } else {
              print('Login failed with status: ${response.statusCode}');
            }
          });

      print(response);
    } catch (e) {
      print('Error during login: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Screen')),
      body: const Center(child: Text('This is the Login Screen')),
    );
  }
}

class LoginPage {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: const Center(child: Text('This is the Login Page')),
    );
  }
}
