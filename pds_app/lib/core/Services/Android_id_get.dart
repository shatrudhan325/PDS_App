import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_id/android_id.dart';

class DeviceInfoService {
  static const String _androidIdKey = 'android_id';

  /// Get & cache Android ID in SharedPreferences
  static Future<String?> getAndroidId() async {
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

  /// Get saved Android ID (no fresh fetch)
  static Future<String?> getSavedAndroidId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_androidIdKey);
  }

  /// Optional: clear cached Android ID (e.g. on logout)
  static Future<void> clearAndroidId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_androidIdKey);
  }
}
