import 'package:jwt_decoder/jwt_decoder.dart';
import 'token_store.dart';

class TokenDecoder {
  // Return the whole decoded token or null if no token / invalid
  static Future<Map<String, dynamic>?> decode() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) return null;
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      print("JWT decode error: $e");
      return null;
    }
  }

  // Get user id (as String)
  static Future<String?> getUserId() async {
    final decoded = await decode();
    if (decoded == null) return null;
    final id = decoded["id"];
    return id?.toString();
  }

  // Get user name (supports "name" or "username" claims)
  static Future<String?> getName() async {
    final decoded = await decode();
    if (decoded == null) return null;
    if (decoded.containsKey('name')) return decoded['name']?.toString();
    if (decoded.containsKey('username')) return decoded['username']?.toString();
    // fallback to sub claim
    if (decoded.containsKey('sub')) return decoded['sub']?.toString();
    return null;
  }

  // Get role(s) as a readable string. Handles a string or a list in the token.
  static Future<String?> getRole() async {
    final decoded = await decode();
    if (decoded == null) return null;

    final dynamic roles =
        decoded['roles'] ?? decoded['role'] ?? decoded['roleName'];

    if (roles == null) return null;

    if (roles is String) {
      return roles;
    } else if (roles is List) {
      // join into single comma separated string
      return roles.map((r) => r.toString()).join(', ');
    } else {
      // last resort: convert to string
      return roles.toString();
    }
  }
}
