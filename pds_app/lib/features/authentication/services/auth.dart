import 'dart:convert';
import 'dart:io';
import 'package:pds_app/core/Services/token_store.dart'; //new
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
        final token = data['accessToken'];
        await TokenStorage.saveToken(token);

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("accessToken", token);

          if (!JwtDecoder.isExpired(token)) {
            final decodedToken = JwtDecoder.decode(token);
            print('Decoded Token User ID: ${decodedToken['id']}');
            print('Token Expires At: ${JwtDecoder.getExpirationDate(token)}');
          }

          print('Token saved: $prefs.getString("accessToken")');
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

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_androidIdKey); // optional: clear cached androidId too
  }
}
