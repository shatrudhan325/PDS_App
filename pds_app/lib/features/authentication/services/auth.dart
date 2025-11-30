// import 'dart:convert';
// import 'dart:io';
// import 'package:pds_app/core/Services/token_store.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:sim_card_code/sim_card_code.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:android_id/android_id.dart';

// class AuthService {
//   static const String _baseUrl = 'http://192.168.29.202:8080/v1/m/auth/login';
//   static const String _tokenKey = 'auth_token';
//   static const String _androidIdKey = 'android_id';

//   static PackageInfo? _packageInfo;
//   static Future<void> _loadPackageInfo() async {
//     if (_packageInfo == null) {
//       _packageInfo = await PackageInfo.fromPlatform();
//     }
//   }

//   static String cleanMobileNumber(String number) {
//     final cleaned = number.replaceAll(RegExp(r'[^0-9]'), '');
//     if (cleaned.length > 10) {
//       return cleaned.substring(cleaned.length - 10);
//     }
//     return cleaned;
//   }
//   static Future<String?> _getAndroidId() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cached = prefs.getString(_androidIdKey);
//       if (cached != null && cached.isNotEmpty) {
//         print('Using cached Android ID: $cached');
//         return cached;
//       }
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

//   static Future<String?> getSavedAndroidId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_androidIdKey);
//   }
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
//     final String? androidId = await _getAndroidId();

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

//       print(response.body);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final token = data['accessToken'];
//         await TokenStorage.saveToken(token);

//         if (token != null) {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString("accessToken", token);

//           if (!JwtDecoder.isExpired(token)) {
//             final decodedToken = JwtDecoder.decode(token);
//             print('Decoded Token User ID: ${decodedToken['id']}');
//             print('Token Expires At: ${JwtDecoder.getExpirationDate(token)}');
//           }

//           print('Token saved: $prefs.getString("accessToken")');
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

//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }

//   static Future<bool> isLoggedIn() async {
//     final token = await getToken();
//     if (token == null) return false;
//     return !JwtDecoder.isExpired(token);
//   }

//   static Future<void> saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_tokenKey, token);
//   }

//   static Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//     await prefs.remove(_androidIdKey);
//   }
// }

////Uper wala code sahi hai tested code hai.
///Using Dio.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sim_card_code/sim_card_code.dart';
import 'package:android_id/android_id.dart';

import 'dio_client.dart';
import 'token_store.dart';

class AuthService {
  static const String _loginUrl = 'http://192.168.29.202:8080/v1/m/auth/login';
  //static const String _tokenKey = 'auth_token';
  static PackageInfo? _packageInfo;

  static Future<void> _loadPackageInfo() async {
    if (_packageInfo == null) {
      _packageInfo = await PackageInfo.fromPlatform();
    }
  }

  static String cleanMobileNumber(String number) {
    final cleaned = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length > 10) {
      return cleaned.substring(cleaned.length - 10);
    }
    return cleaned;
  }

  static Future<String?> _getAndroidId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('android_id');
      if (cached != null && cached.isNotEmpty) {
        print('Using cached Android ID: $cached');
        return cached;
      }
      final androidIdPlugin = AndroidId();
      final String? androidId = await androidIdPlugin.getId();

      if (androidId != null && androidId.isNotEmpty) {
        await prefs.setString('android_id', androidId);
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

  /// Login API + send phoneNumber (10 digits) + buildNumber + applicationVersion + androidId
  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    await _loadPackageInfo();

    final String? firstSimMobile = await _getFirstSimMobileNumber();
    final String? androidId = await _getAndroidId();

    try {
      final Map<String, dynamic> body = {
        'username': username.trim(),
        'password': password.trim(),
        'phoneNumber': firstSimMobile ?? '',
        'buildNumber': androidId ?? '',
        'applicationVersion': _packageInfo?.version ?? '',
      };

      print('Login request body: $body');

      final dio = DioClient().dio;
      final response = await dio.post(_loginUrl, data: body);
      print('response $response');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final token = data['accessToken'] as String?;
        final refresh = data['refreshToken'] as String?;

        if (token != null && token.isNotEmpty) {
          await TokenStorage.saveAccessToken(token);
          // final role = extractRole(token); //role
          // if (role != null) {
          //   final prefs = await SharedPreferences.getInstance();
          //   await prefs.setString("user_role", role);
          // }
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', token);
          if (refresh != null && refresh.isNotEmpty) {
            await TokenStorage.saveRefreshToken(refresh);
          }

          if (!JwtDecoder.isExpired(token)) {
            final decodedToken = JwtDecoder.decode(token);
            print('Decoded Token User ID: ${decodedToken['id']}');
            print('Decoded Token: ${decodedToken}');
            print('Token Expires At: ${JwtDecoder.getExpirationDate(token)}');
          }

          print('Token saved: ${prefs.getString("accessToken")}');
        }
        return data;
      } else {
        print('Login failed: ${response.statusCode} ${response.data}');
        String errorMessage = 'Invalid credentials or server error.';
        try {
          final errorData = response.data;
          if (errorData is Map &&
              (errorData['message'] != null || errorData['error'] != null)) {
            errorMessage =
                errorData['message'] ?? errorData['error'] ?? errorMessage;
          } else if (errorData is String) {
            errorMessage = errorData;
          }
        } catch (_) {}
        return {'error': errorMessage};
      }
    } on DioException catch (e) {
      print('DioException during login: ${e.message}');
      String errMsg = 'Cannot connect to the server.';
      if (e.response != null) {
        try {
          final d = e.response!.data;
          if (d is Map && d['message'] != null)
            errMsg = d['message'];
          else if (d is String)
            errMsg = d;
        } catch (_) {}
      }
      return {'error': errMsg};
    } catch (e) {
      print('Error during login: $e');
      return {'error': 'Unexpected error during login.'};
    }
  }

  static Future<String?> getToken() async {
    return await TokenStorage.getAccessToken();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    return !JwtDecoder.isExpired(token);
  }

  static Future<void> saveToken(String token) async {
    await TokenStorage.saveAccessToken(token);
  }

  static Future<void> logout() async {
    await TokenStorage.clearAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('android_id');
  }
}

String? extractRole(String token) {
  try {
    final decoded = JwtDecoder.decode(token);
    final role = decoded["roles"];
    if (role is String) return role;
    return null;
  } catch (e) {
    print("Role decode error: $e");
    return null;
  }
}
