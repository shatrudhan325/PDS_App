import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final role = RxnString();

  Future<void> loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    role.value = prefs.getString("roles");
  }

  void setRole(String? r) {
    role.value = r;
  }

  bool get isLoggedIn => role.value != null;
}
