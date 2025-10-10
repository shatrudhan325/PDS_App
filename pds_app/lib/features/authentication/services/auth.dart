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
// //Updated Code:
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   static const String _baseUrl = 'https://dummyjson.com/auth/login';
//   static const String _tokenKey = 'auth_token';

//   /// ✅ Login API + save token
//   static Future<Map<String, dynamic>?> login(
//     String username,
//     String password,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse(_baseUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username.trim(),
//           'password': password.trim(),
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final token = data['token'];
//         if (token != null) {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString(_tokenKey, token);
//           print('✅ Token saved: $token');
//         }
//         return data;
//       } else {
//         print('❌ Login failed: ${response.statusCode} ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print('⚠️ Error during login: $e');
//       return null;
//     }
//   }

//   /// ✅ Check if token already saved (auto-login)
//   static Future<bool> isLoggedIn() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(_tokenKey);
//     return token != null && token.isNotEmpty;
//   }

//   /// ✅ Logout and clear token
//   static Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//     print('🚪 Token removed');
//   }
// }
