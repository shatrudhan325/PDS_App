// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:pds_app/core/apiConfig/config.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   TextEditingController usernameController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();

//   bool loading = false;
//   void login() async {
//     setState(() {
//       loading = true;
//     });
//     try {
//       print("In try");
//       final response = await http
//           .post(
//             Uri.parse('https://dummyjson.com/auth/login'),
//             body: jsonEncode({
//               'username': usernameController.text,
//               'password': passwordController.text,
//             }),
//           )
//           .then((response) {
//             if (response.statusCode == 200) {
//               print('Login successful: ${response.body}');
//             } else {
//               print('Login failed with status: ${response.statusCode}');
//             }
//           });

//       print(response);
//       print(ApiConfig.baseURL);
//     } catch (e) {
//       print('Error during the login: $e');
//     } finally {
//       setState(() {
//         loading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login Screen')),
//       body: const Center(child: Text('This is the Login Screen')),
//     );
//   }
// }

// class LoginPage {
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login Page')),
//       body: const Center(child: Text('This is the Login Page')),
//     );
//   }
// }

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

// //Gemini Updated Code total write code
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

//   // Login API + save token ho rha hai
//   // The function now returns a Map<String, dynamic> containing EITHER success data OR an 'error' key.
//   static Future<Map<String, dynamic>?> login(
//     String username,
//     String password,
//   ) async {
//     await _loadPackageInfo();

//     print(
//       'Logging in from App Version: ${_packageInfo?.version}, Build Number: ${_packageInfo?.buildNumber}',
//     );

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
//             print('Decoded Token User ID: ${decodedToken['id']}');
//             print('Token Expires At: ${JwtDecoder.getExpirationDate(token)}');
//           }

//           print('Token saved: $token');
//         }
//         return data; // Returns success data (e.g., user info)
//       } else {
//         print('Login failed: ${response.statusCode} ${response.body}');

//         String errorMessage = 'Invalid credentials or server error.';
//         try {
//           final errorData = jsonDecode(response.body);
//           // Look for common error fields from Spring Boot like 'message' or 'error'
//           errorMessage =
//               errorData['message'] ?? errorData['error'] ?? errorMessage;
//         } catch (_) {
//           // Ignore if body is not JSON
//         }

//         // Return a Map explicitly marking the failure
//         return {'error': errorMessage};
//       }
//     } catch (e) {
//       // CHANGE 3: Improved Network Error Handling
//       print(' Error during login: $e');
//       // Return a Map with a specific network error message
//       return {
//         'error':
//             'Cannot connect to the server. Check your connection or API URL.',
//       };
//     }
//   }

//   // ... (getToken, isLoggedIn, logout methods remain unchanged)
// }

// // code is after apply mobile number gets
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:mobile_number/mobile_number.dart';

// class AuthService {
//   static const String _baseUrl = 'http://10.0.2.2:8080/auth/login';
//   static const String _tokenKey = 'auth_token';

//   static PackageInfo? _packageInfo;

//   static Future<void> _loadPackageInfo() async {
//     if (_packageInfo == null) {
//       _packageInfo = await PackageInfo.fromPlatform();
//     }
//   }

//   static Future<Map<String, dynamic>?> login(
//     String username,
//     String password,
//   ) async {
//     await _loadPackageInfo();

//     print(
//       'Logging in from App Version: ${_packageInfo?.version}, Build Number: ${_packageInfo?.buildNumber}',
//     );

//     String? firstSimNumber;
//     try {
//       bool permissionGranted = await MobileNumber.hasPhonePermission;
//       if (!permissionGranted) {
//         permissionGranted = await MobileNumber.requestPhonePermission;
//       }

//       if (permissionGranted) {
//         try {
//           List<SimCard>? simCards = await MobileNumber.getSimCards;
//           if (simCards != null && simCards.isNotEmpty) {
//             firstSimNumber = simCards
//                 .firstWhere(
//                   (s) => s.number != null && s.number!.trim().isNotEmpty,
//                   orElse: () => simCards.first,
//                 )
//                 .number;
//           } else {
//             firstSimNumber = await MobileNumber.mobileNumber;
//           }
//         } catch (e) {
//           print('Warning: failed to read sim cards: $e');
//         }
//       } else {
//         print('Phone permission not granted; skipping SIM number read.');
//       }
//     } catch (e) {
//       print('Error while trying to read mobile number: $e');
//     }

//     try {
//       final bodyMap = {
//         'username': username.trim(),
//         'password': password.trim(),
//       };
//       if (firstSimNumber != null && firstSimNumber.trim().isNotEmpty) {
//         bodyMap['mobile'] = firstSimNumber.trim();
//         print('Including mobile in login request: $firstSimNumber');
//       } else {
//         print('No mobile number available, sending login without mobile.');
//       }

//       final response = await http.post(
//         Uri.parse(_baseUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(bodyMap),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final token = data['token'];

//         if (token != null) {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString(_tokenKey, token);

//           if (!JwtDecoder.isExpired(token)) {
//             Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
//             print('Decoded Token User ID: ${decodedToken['id']}');
//             print('Token Expires At: ${JwtDecoder.getExpirationDate(token)}');
//           }

//           print('Token saved: $token');
//         }
//         return data;
//       } else {
//         print('Login failed: ${response.statusCode} ${response.body}');
//         String errorMessage = 'Invalid credentials or server error.';
//         try {
//           final errorData = jsonDecode(response.body);
//           errorMessage =
//               errorData['message'] ?? errorData['error'] ?? errorMessage;
//         } catch (_) {}
//         return {'error': errorMessage};
//       }
//     } catch (e) {
//       print(' Error during login: $e');
//       return {
//         'error':
//             'Cannot connect to the server. Check your connection or API URL.',
//       };
//     }
//   }
// }

//sim card read code

// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// // New imports
// import 'package:sim_card_code/sim_card_code.dart';
// import 'package:permission_handler/permission_handler.dart';

// class AuthService {
//   static const String _baseUrl = 'http://192.168.29.202:8080/auth/m/login';
//   static const String _tokenKey = 'auth_token';

//   static PackageInfo? _packageInfo;

//   static Future<void> _loadPackageInfo() async {
//     if (_packageInfo == null) {
//       _packageInfo = await PackageInfo.fromPlatform();
//     }
//   }

//   /// Get first SIM mobile number (if available) using sim_card_code
//   static Future<String?> _getFirstSimMobileNumber() async {
//     try {
//       // Only Android / iOS supported; if anything else, just skip
//       if (!Platform.isAndroid && !Platform.isIOS) return null;

//       // Request runtime permission on Android
//       if (Platform.isAndroid) {
//         var status = await Permission.phone.status;
//         if (!status.isGranted) {
//           status = await Permission.phone.request();
//           if (!status.isGranted) {
//             print('Phone permission not granted.');
//             return null;
//           }
//         }
//       }

//       // Check SIM presence
//       final bool hasSim = await SimCardManager.hasSimCard;
//       if (!hasSim) {
//         print('No SIM card detected.');
//         return null;
//       }

//       // 1) Try all SIMs (dual SIM support)
//       try {
//         final List<SimCardInfo> allSimInfo = await SimCardManager.allSimInfo;
//         if (allSimInfo.isNotEmpty) {
//           for (final sim in allSimInfo) {
//             final String? num = sim.phoneNumber?.trim();
//             if (num != null && num.isNotEmpty) {
//               print('Using phone number from allSimInfo: $num');
//               return num;
//             }
//           }
//         }
//       } catch (e) {
//         print('Error reading allSimInfo: $e');
//       }

//       // 2) Fallback: basicSimInfo (primary SIM)
//       try {
//         final SimCardInfo? basic = await SimCardManager.basicSimInfo;
//         final String? num = basic?.phoneNumber?.trim();
//         if (num != null && num.isNotEmpty) {
//           print('Using phone number from basicSimInfo: $num');
//           return num;
//         }
//       } catch (e) {
//         print('Error reading basicSimInfo: $e');
//       }
//     } catch (e) {
//       print('Error in _getFirstSimMobileNumber: $e');
//     }

//     // Nothing available (very common on newer Android versions)
//     return null;
//   }

//   /// Login API + save token + send first SIM mobile number (if available)
//   static Future<Map<String, dynamic>?> login(
//     String username,
//     String password,
//   ) async {
//     await _loadPackageInfo();

//     print(
//       'Logging in from App Version: ${_packageInfo?.version}, Build Number: ${_packageInfo?.buildNumber}',
//     );

//     // Try to get SIM mobile number (may be null)
//     final String? firstSimMobile = await _getFirstSimMobileNumber();

//     try {
//       // Build request body
//       final Map<String, dynamic> body = {
//         'username': username.trim(),
//         'password': password.trim(),
//       };

//       // Only send mobile if we actually got one
//       if (firstSimMobile != null && firstSimMobile.isNotEmpty) {
//         body['mobile'] = firstSimMobile;
//         print('Including mobile in login request: $firstSimMobile');
//       } else {
//         print('No SIM mobile available, sending login without mobile.');
//       }

//       final response = await http.post(
//         Uri.parse(_baseUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(body),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final token = data['token'];

//         if (token != null) {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString(_tokenKey, token);

//           if (!JwtDecoder.isExpired(token)) {
//             final decodedToken = JwtDecoder.decode(token);
//             print('Decoded Token User ID: ${decodedToken['id']}');
//             print('Token Expires At: ${JwtDecoder.getExpirationDate(token)}');
//           }

//           print('Token saved: $token');
//         }
//         return data;
//       } else {
//         print('Login failed: ${response.statusCode} ${response.body}');

//         String errorMessage = 'Invalid credentials or server error.';
//         try {
//           final errorData = jsonDecode(response.body);
//           errorMessage =
//               errorData['message'] ?? errorData['error'] ?? errorMessage;
//         } catch (_) {}

//         return {'error': errorMessage};
//       }
//     } catch (e) {
//       print('Error during login: $e');
//       return {
//         'error':
//             'Cannot connect to the server. Check your connection or API URL.',
//       };
//     }
//   }

//   // ===== Optional: other helper methods (if you already have them, keep those) =====
//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }

//   static Future<bool> isLoggedIn() async {
//     final token = await getToken();
//     if (token == null) return false;
//     return !JwtDecoder.isExpired(token);
//   }

//   static Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//   }
// }

// All Ok Code but Build Number Is not Working.
// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// // New imports
// import 'package:sim_card_code/sim_card_code.dart';
// import 'package:permission_handler/permission_handler.dart';

// class AuthService {
//   static const String _baseUrl = 'http://192.168.29.202:8080/auth/m/login';
//   static const String _tokenKey = 'auth_token';

//   static PackageInfo? _packageInfo;

//   static Future<void> _loadPackageInfo() async {
//     if (_packageInfo == null) {
//       _packageInfo = await PackageInfo.fromPlatform();
//     }
//   }

//   /// Get first SIM mobile number (if available)
//   static Future<String?> _getFirstSimMobileNumber() async {
//     try {
//       if (!Platform.isAndroid && !Platform.isIOS) return null;

//       if (Platform.isAndroid) {
//         var status = await Permission.phone.status;
//         if (!status.isGranted) {
//           status = await Permission.phone.request();
//           if (!status.isGranted) {
//             print('Phone permission not granted.');
//             return null;
//           }
//         }
//       }

//       final bool hasSim = await SimCardManager.hasSimCard;
//       if (!hasSim) {
//         print('No SIM card detected.');
//         return null;
//       }

//       // Try dual SIM info
//       try {
//         final List<SimCardInfo> allSimInfo = await SimCardManager.allSimInfo;
//         if (allSimInfo.isNotEmpty) {
//           for (final sim in allSimInfo) {
//             final String? num = sim.phoneNumber?.trim();
//             if (num != null && num.isNotEmpty) {
//               print('Using phone number from allSimInfo: $num');
//               return num;
//             }
//           }
//         }
//       } catch (e) {
//         print('Error reading allSimInfo: $e');
//       }

//       // Fallback primary SIM
//       try {
//         final SimCardInfo? basic = await SimCardManager.basicSimInfo;
//         final String? num = basic?.phoneNumber?.trim();
//         if (num != null && num.isNotEmpty) {
//           print('Using phone number from basicSimInfo: $num');
//           return num;
//         }
//       } catch (e) {
//         print('Error reading basicSimInfo: $e');
//       }
//     } catch (e) {
//       print('Error in _getFirstSimMobileNumber: $e');
//     }

//     return null;
//   }

//   /// Login API + send phoneNumber + buildNumber + applicationVersion
//   static Future<Map<String, dynamic>?> login(
//     String username,
//     String password,
//   ) async {
//     await _loadPackageInfo();

//     final String? firstSimMobile = await _getFirstSimMobileNumber();

//     try {
//       //Send data in backend.
//       final Map<String, dynamic> body = {
//         'username': username.trim(),
//         'password': password.trim(),
//         'phoneNumber': firstSimMobile ?? '',
//         'buildNumber': _packageInfo?.buildNumber ?? '',
//         'applicationVersion': _packageInfo?.version ?? '',
//       };

//       print('Login request body: $body');

//       final response = await http.post(
//         Uri.parse(_baseUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(body),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final token = data['token'];

//         if (token != null) {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString(_tokenKey, token);

//           if (!JwtDecoder.isExpired(token)) {
//             final decodedToken = JwtDecoder.decode(token);
//             print('Decoded Token User ID: ${decodedToken['id']}');
//             print('Token Expires At: ${JwtDecoder.getExpirationDate(token)}');
//           }

//           print('Token saved: $token');
//         }
//         return data;
//       } else {
//         print('Login failed: ${response.statusCode} ${response.body}');

//         String errorMessage = 'Invalid credentials or server error.';
//         try {
//           final errorData = jsonDecode(response.body);
//           errorMessage =
//               errorData['message'] ?? errorData['error'] ?? errorMessage;
//         } catch (_) {}

//         return {'error': errorMessage};
//       }
//     } catch (e) {
//       print('Error during login: $e');
//       return {
//         'error':
//             'Cannot connect to the server. Check your connection or API URL.',
//       };
//     }
//   }

//   // Helpers
//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }

//   static Future<bool> isLoggedIn() async {
//     final token = await getToken();
//     if (token == null) return false;
//     return !JwtDecoder.isExpired(token);
//   }

//   static Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//   }
// }

//Update code
// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// // New imports
// import 'package:sim_card_code/sim_card_code.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:android_id/android_id.dart';

// class AuthService {
//   static const String _baseUrl = 'http://192.168.29.202:8080/auth/m/login';
//   static const String _tokenKey = 'auth_token';
//   static const String _androidIdKey = 'android_id';

//   static PackageInfo? _packageInfo;

//   static Future<void> _loadPackageInfo() async {
//     if (_packageInfo == null) {
//       _packageInfo = await PackageInfo.fromPlatform();
//     }
//   }

//   /// Get & cache Android ID in SharedPreferences
//   static Future<String?> _getAndroidId() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Use cached value if present
//       final cached = prefs.getString(_androidIdKey);
//       if (cached != null && cached.isNotEmpty) {
//         print('Using cached Android ID: $cached');
//         return cached;
//       }

//       // Otherwise fetch from plugin
//       final androidIdPlugin = AndroidId();
//       final String? androidId = await androidIdPlugin.getId();

//       if (androidId != null && androidId.isNotEmpty) {
//         await prefs.setString(_androidIdKey, androidId);
//         print('Fetched & saved Android ID: $androidId');
//       } else {
//         print('Android ID is null or empty');
//       }

//       return androidId;
//     } catch (e) {
//       print('Error getting Android ID: $e');
//       return null;
//     }
//   }

//   /// Optional public getter for Android ID from SharedPreferences
//   static Future<String?> getSavedAndroidId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_androidIdKey);
//   }

//   /// Get first SIM mobile number (if available)
//   static Future<String?> _getFirstSimMobileNumber() async {
//     try {
//       if (!Platform.isAndroid && !Platform.isIOS) return null;

//       if (Platform.isAndroid) {
//         var status = await Permission.phone.status;
//         if (!status.isGranted) {
//           status = await Permission.phone.request();
//           if (!status.isGranted) {
//             print('Phone permission not granted.');
//             return null;
//           }
//         }
//       }

//       final bool hasSim = await SimCardManager.hasSimCard;
//       if (!hasSim) {
//         print('No SIM card detected.');
//         return null;
//       }

//       // Try dual SIM info
//       try {
//         final List<SimCardInfo> allSimInfo = await SimCardManager.allSimInfo;
//         if (allSimInfo.isNotEmpty) {
//           for (final sim in allSimInfo) {
//             final String? num = sim.phoneNumber?.trim();
//             if (num != null && num.isNotEmpty) {
//               print('Using phone number from allSimInfo: $num');
//               return num;
//             }
//           }
//         }
//       } catch (e) {
//         print('Error reading allSimInfo: $e');
//       }

//       // Fallback primary SIM
//       try {
//         final SimCardInfo? basic = await SimCardManager.basicSimInfo;
//         final String? num = basic?.phoneNumber?.trim();
//         if (num != null && num.isNotEmpty) {
//           print('Using phone number from basicSimInfo: $num');
//           return num;
//         }
//       } catch (e) {
//         print('Error reading basicSimInfo: $e');
//       }
//     } catch (e) {
//       print('Error in _getFirstSimMobileNumber: $e');
//     }

//     return null;
//   }

//   /// Login API + send phoneNumber + buildNumber + applicationVersion + androidId
//   static Future<Map<String, dynamic>?> login(
//     String username,
//     String password,
//   ) async {
//     await _loadPackageInfo();

//     final String? firstSimMobile = await _getFirstSimMobileNumber();
//     final String? androidId = await _getAndroidId();

//     try {
//       // Send data to backend
//       final Map<String, dynamic> body = {
//         'username': username.trim(),
//         'password': password.trim(),
//         'phoneNumber': firstSimMobile ?? '',
//         'androidId': androidId ?? '',
//         'applicationVersion': _packageInfo?.version ?? '',
//       };

//       print('Login request body: $body');

//       final response = await http.post(
//         Uri.parse(_baseUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(body),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final token = data['token'];

//         if (token != null) {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString(_tokenKey, token);

//           if (!JwtDecoder.isExpired(token)) {
//             final decodedToken = JwtDecoder.decode(token);
//             print('Decoded Token User ID: ${decodedToken['id']}');
//             print('Token Expires At: ${JwtDecoder.getExpirationDate(token)}');
//           }

//           print('Token saved: $token');
//         }
//         return data;
//       } else {
//         print('Login failed: ${response.statusCode} ${response.body}');

//         String errorMessage = 'Invalid credentials or server error.';
//         try {
//           final errorData = jsonDecode(response.body);
//           errorMessage =
//               errorData['message'] ?? errorData['error'] ?? errorMessage;
//         } catch (_) {}

//         return {'error': errorMessage};
//       }
//     } catch (e) {
//       print('Error during login: $e');
//       return {
//         'error':
//             'Cannot connect to the server. Check your connection or API URL.',
//       };
//     }
//   }

//   // Helpers
//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }

//   static Future<bool> isLoggedIn() async {
//     final token = await getToken();
//     if (token == null) return false;
//     return !JwtDecoder.isExpired(token);
//   }

//   static Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//     await prefs.remove(_androidIdKey); // optional: clear cached androidId too
//   }
// }

// //Yaha se main Code Hai. jo prince sir tested code.
// ///updated Code
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:package_info_plus/package_info_plus.dart';

// New imports
import 'package:sim_card_code/sim_card_code.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_id/android_id.dart';

class AuthService {
  static const String _baseUrl = 'http://192.168.29.202:8080/v1/m/auth/login';
  static const String _tokenKey = 'auth_token';
  static const String _androidIdKey = 'android_id';

  static PackageInfo? _packageInfo;

  // ----------------- Helpers -----------------

  static Future<void> _loadPackageInfo() async {
    if (_packageInfo == null) {
      _packageInfo = await PackageInfo.fromPlatform();
    }
  }

  /// Remove +91 or any country code and return only digits (last 10)
  static String cleanMobileNumber(String number) {
    // Remove everything except digits
    final cleaned = number.replaceAll(RegExp(r'[^0-9]'), '');

    // For Indian numbers: take last 10 digits if longer
    if (cleaned.length > 10) {
      return cleaned.substring(cleaned.length - 10);
    }

    return cleaned;
  }

  /// Get & cache Android ID in SharedPreferences
  static Future<String?> _getAndroidId() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Use cached value if present
      final cached = prefs.getString(_androidIdKey);
      if (cached != null && cached.isNotEmpty) {
        print('Using cached Android ID: $cached');
        return cached;
      }

      // Otherwise fetch from plugin
      final androidIdPlugin = AndroidId();
      final String? androidId = await androidIdPlugin.getId();

      if (androidId != null && androidId.isNotEmpty) {
        await prefs.setString(_androidIdKey, androidId);
        print('Fetched & saved Android ID: $androidId');
      } else {
        print('Android ID is null or empty');
      }

      return androidId;
    } catch (e) {
      print('Error getting Android ID: $e');
      return null;
    }
  }

  /// Optional public getter for Android ID from SharedPreferences
  static Future<String?> getSavedAndroidId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_androidIdKey);
  }

  /// Get first SIM mobile number (if available), cleaned (10 digits, no +91)
  static Future<String?> _getFirstSimMobileNumber() async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) return null;

      if (Platform.isAndroid) {
        var status = await Permission.phone.status;
        if (!status.isGranted) {
          status = await Permission.phone.request();
          if (!status.isGranted) {
            print('Phone permission not granted.');
            return null;
          }
        }
      }

      final bool hasSim = await SimCardManager.hasSimCard;
      if (!hasSim) {
        print('No SIM card detected.');
        return null;
      }

      // Try dual SIM info
      try {
        final List<SimCardInfo> allSimInfo = await SimCardManager.allSimInfo;
        if (allSimInfo.isNotEmpty) {
          for (final sim in allSimInfo) {
            final String? num = sim.phoneNumber?.trim();
            if (num != null && num.isNotEmpty) {
              final cleaned = cleanMobileNumber(num);
              print('Using phone number from allSimInfo: $cleaned');
              return cleaned;
            }
          }
        }
      } catch (e) {
        print('Error reading allSimInfo: $e');
      }

      // Fallback primary SIM
      try {
        final SimCardInfo? basic = await SimCardManager.basicSimInfo;
        final String? num = basic?.phoneNumber?.trim();
        if (num != null && num.isNotEmpty) {
          final cleaned = cleanMobileNumber(num);
          print('Using phone number from basicSimInfo: $cleaned');
          return cleaned;
        }
      } catch (e) {
        print('Error reading basicSimInfo: $e');
      }
    } catch (e) {
      print('Error in _getFirstSimMobileNumber: $e');
    }

    return null;
  }

  // ----------------- Login -----------------

  /// Login API + send phoneNumber (10 digits) + buildNumber + applicationVersion + androidId
  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    await _loadPackageInfo();

    final String? firstSimMobile = await _getFirstSimMobileNumber();
    final String? androidId = await _getAndroidId();

    try {
      // Send data to backend
      final Map<String, dynamic> body = {
        'username': username.trim(),
        'password': password.trim(),
        'phoneNumber': firstSimMobile ?? '',
        'buildNumber': androidId ?? '',
        'applicationVersion': _packageInfo?.version ?? '',
      };

      print('Login request body: $body');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);

          if (!JwtDecoder.isExpired(token)) {
            final decodedToken = JwtDecoder.decode(token);
            print('Decoded Token User ID: ${decodedToken['id']}');
            print('Token Expires At: ${JwtDecoder.getExpirationDate(token)}');
          }

          print('Token saved: $token');
        }
        return data;
      } else {
        print('Login failed: ${response.statusCode} ${response.body}');

        String errorMessage = 'Invalid credentials or server error.';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage =
              errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {}

        return {'error': errorMessage};
      }
    } catch (e) {
      print('Error during login: $e');
      return {
        'error':
            'Cannot connect to the server. Check your connection or API URL.',
      };
    }
  }

  // ----------------- Auth Helpers -----------------

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_androidIdKey); // optional: clear cached androidId too
  }
}
//

//Tested Code Uper Wala Hai.
//New code after extract android id function
// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'package:pds_app/core/Services/Android_id_get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// // New imports
// import 'package:sim_card_code/sim_card_code.dart';
// import 'package:permission_handler/permission_handler.dart';

// class AuthService {
//   static const String _baseUrl = 'http://192.168.29.202:8080/auth/m/login';
//   static const String _tokenKey = 'auth_token';

//   static PackageInfo? _packageInfo;

//   static Future<void> _loadPackageInfo() async {
//     if (_packageInfo == null) {
//       _packageInfo = await PackageInfo.fromPlatform();
//     }
//   }

//   /// Remove +91 or any country code and return only digits (last 10)
//   static String cleanMobileNumber(String number) {
//     // Remove everything except digits
//     final cleaned = number.replaceAll(RegExp(r'[^0-9]'), '');

//     // For Indian numbers: take last 10 digits if longer
//     if (cleaned.length > 10) {
//       return cleaned.substring(cleaned.length - 10);
//     }

//     return cleaned;
//   }

//   /// Get first SIM mobile number (if available), cleaned (10 digits, no +91)
//   static Future<String?> _getFirstSimMobileNumber() async {
//     try {
//       if (!Platform.isAndroid && !Platform.isIOS) return null;

//       if (Platform.isAndroid) {
//         var status = await Permission.phone.status;
//         if (!status.isGranted) {
//           status = await Permission.phone.request();
//           if (!status.isGranted) {
//             print('Phone permission not granted.');
//             return null;
//           }
//         }
//       }

//       final bool hasSim = await SimCardManager.hasSimCard;
//       if (!hasSim) {
//         print('No SIM card detected.');
//         return null;
//       }

//       // Try dual SIM info
//       try {
//         final List<SimCardInfo> allSimInfo = await SimCardManager.allSimInfo;
//         if (allSimInfo.isNotEmpty) {
//           for (final sim in allSimInfo) {
//             final String? num = sim.phoneNumber?.trim();
//             if (num != null && num.isNotEmpty) {
//               final cleaned = cleanMobileNumber(num);
//               print('Using phone number from allSimInfo: $cleaned');
//               return cleaned;
//             }
//           }
//         }
//       } catch (e) {
//         print('Error reading allSimInfo: $e');
//       }

//       // Fallback primary SIM
//       try {
//         final SimCardInfo? basic = await SimCardManager.basicSimInfo;
//         final String? num = basic?.phoneNumber?.trim();
//         if (num != null && num.isNotEmpty) {
//           final cleaned = cleanMobileNumber(num);
//           print('Using phone number from basicSimInfo: $cleaned');
//           return cleaned;
//         }
//       } catch (e) {
//         print('Error reading basicSimInfo: $e');
//       }
//     } catch (e) {
//       print('Error in _getFirstSimMobileNumber: $e');
//     }

//     return null;
//   }

//   /// Login API + send phoneNumber (10 digits) + buildNumber + applicationVersion + androidId
//   static Future<Map<String, dynamic>?> login(
//     String username,
//     String password,
//   ) async {
//     await _loadPackageInfo();

//     final String? firstSimMobile = await _getFirstSimMobileNumber();

//     final String? androidId = await DeviceInfoService.getAndroidId();

//     try {
//       // Send data to backend
//       final Map<String, dynamic> body = {
//         'username': username.trim(),
//         'password': password.trim(),
//         'phoneNumber': firstSimMobile ?? '',
//         'buildNumber': androidId ?? '',
//         'applicationVersion': _packageInfo?.version ?? '',
//       };

//       print('Login request body: $body');

//       final response = await http.post(
//         Uri.parse(_baseUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(body),
//       );

//       print(response);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final token = data['token'];

//         if (token != null) {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString(_tokenKey, token);

//           if (!JwtDecoder.isExpired(token)) {
//             final decodedToken = JwtDecoder.decode(token);
//             print('Decoded Token User ID: ${decodedToken['id']}');
//             print('Token Expires At: ${JwtDecoder.getExpirationDate(token)}');
//           }

//           print('Token saved: $token');
//         }
//         return data;
//       } else {
//         print('Login failed: ${response.statusCode} ${response.body}');

//         String errorMessage = 'Invalid credentials or server error.';
//         try {
//           final errorData = jsonDecode(response.body);
//           errorMessage =
//               errorData['message'] ?? errorData['error'] ?? errorMessage;
//         } catch (_) {}

//         return {'error': errorMessage};
//       }
//     } catch (e) {
//       print('Error during login: $e');
//       return {
//         'error':
//             'Cannot connect to the server. Check your connection or API URL.',
//       };
//     }
//   }

//   // ----------------- Auth Helpers -----------------

//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString("storedToken", _tokenKey);
//     return prefs.getString(_tokenKey);
//   }

//   static Future<bool> isLoggedIn() async {
//     final token = await getToken();
//     if (token == null) return false;
//     return !JwtDecoder.isExpired(token);
//   }

//   static Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//   }
// }
