import 'package:jwt_decoder/jwt_decoder.dart';
import 'token_store.dart';

class TokenDecoder {
  static Future<Map<String, dynamic>?> decode() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return null;
    return JwtDecoder.decode(token);
  }

  static Future<String?> getRole() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return null;

    try {
      final decoded = JwtDecoder.decode(token);
      return decoded["roles"];
    } catch (e) {
      print("JWT decode error: $e");
      return null;
    }
  }

  /// Get user id
  static Future<String?> getUserId() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return null;

    final decoded = JwtDecoder.decode(token);
    return decoded["id"].toString();
  }
}
