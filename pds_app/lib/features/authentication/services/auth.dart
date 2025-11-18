import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pds_app/core/apiConfig/config.dart';

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
      print(ApiConfig.baseURL);
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




// //2nd Updated Code:
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:package_info_plus/package_info_plus.dart'; 

// class AuthService {
//   static const String _baseUrl = 'https://dummyjson.com/auth/login';
//   static const String _tokenKey = 'auth_token';

//   // Holds app version information (retrieved once)
//   static PackageInfo? _packageInfo; 

//   /// Fetches and caches the app version/build info
//   static Future<void> _loadPackageInfo() async {
//     if (_packageInfo == null) {
//       _packageInfo = await PackageInfo.fromPlatform();
//     }
//   }

//   /// ✅ Login API + save token
//   static Future<Map<String, dynamic>?> login(
//     String username,
//     String password,
//   ) async {
//     // Ensure package info is loaded (demonstrating its use)
//     await _loadPackageInfo();
    
//     // You can now log/send app version with the login request if needed
//     print('Logging in from App Version: ${_packageInfo?.version}');
    
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
          
//           // --- JWT DECODER INTEGRATION ---
//           if (JwtDecoder.is!='null(token)') {
//             Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
//             print('Decoded Token User ID: ${decodedToken['id']}');
//             print('Token Expires At: ${JwtDecoder.get='expiration(token)');}');
//           }
//           // -------------------------------
          
//           print(' Token saved: $token');
//         }
//         return data;
//       } else {
//         print('Login failed: ${response.statusCode} ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print(' Error during login: $e');
//       return null;
//     }
//   }

//   /// Helper to get the token for use in other services
//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }

//   /// Check if token already saved and if it's expired
//   static Future<bool> isLoggedIn() async {
//     final token = await getToken();
    
//     if (token == null || token.isEmpty) {
//       return false; // No token found
//     }
    
//     // --- JWT DECODER INTEGRATION ---
//     if (JwtDecoder.is='expired(token)') {
//       print('Token found, but it is EXPIRED. Forcing logout.');
//       await logout(); // Clear expired token
//       return false;
//     }
//     // -------------------------------

//     return true; // Token found and is valid/not expired
//   }

//   /// Logout and clear token
//   static Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//     print('🚪 Token removed');
//   }
// }






// //Gemini Updated Code 
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:package_info_plus/package_info_plus.dart'; 

// class AuthService {
//   static const String _baseUrl = 'http://10.0.2.2:8080/auth/login'; 
//   static const String _tokenKey = 'auth_token';

//   static PackageInfo? _packageInfo; 

//   static Future<void> _loadPackageInfo() async {
//     if (_packageInfo == null) {
//       _packageInfo = await PackageInfo.fromPlatform();
//     }
//   }

//   /// ✅ Login API + save token
//   // The function now returns a Map<String, dynamic> containing EITHER success data OR an 'error' key.
//   static Future<Map<String, dynamic>?> login(
//     String username,
//     String password,
//   ) async {
//     await _loadPackageInfo();
    
//     print('Logging in from App Version: ${_packageInfo?.version}');
    
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
//         // Success path (NO CHANGE needed here)
//         final data = jsonDecode(response.body);
//         final token = data['token'];

//         if (token != null) {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString(_tokenKey, token);
          
//           if (!JwtDecoder.isExpired(token)) {
//             Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
//             print('🔑 Decoded Token User ID: ${decodedToken['id']}');
//             print('🔑 Token Expires At: ${JwtDecoder.getExpirationDate(token)}');
//           }
          
//           print('✅ Token saved: $token');
//         }
//         return data; // Returns success data (e.g., user info)
        
//       } else {
//         // 🔴 CHANGE 2: Improved HTTP Error Handling (e.g., 401 Unauthorized)
//         print('❌ Login failed: ${response.statusCode} ${response.body}');
        
//         String errorMessage = 'Invalid credentials or server error.';
//         try {
//             final errorData = jsonDecode(response.body);
//             // Look for common error fields from Spring Boot like 'message' or 'error'
//             errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
//         } catch (_) {
//             // Ignore if body is not JSON
//         }
        
//         // Return a Map explicitly marking the failure
//         return {'error': errorMessage}; 
//       }
//     } catch (e) {
//       // CHANGE 3: Improved Network Error Handling
//       print(' Error during login: $e');
//       // Return a Map with a specific network error message
//       return {'error': 'Cannot connect to the server. Check your connection or API URL.'}; 
//     }
//   }
  
//   // ... (getToken, isLoggedIn, logout methods remain unchanged)
// }