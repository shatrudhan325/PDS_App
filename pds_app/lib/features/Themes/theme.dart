// lib/theme/theme.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// =================================================================
///                  THEME CONTROLLER  (GETX)
/// =================================================================
class ThemeController extends GetxController {
  static const String _storageKey = 'isDarkMode';
  final _box = GetStorage();
  final isDark = false.obs;

  @override
  void onInit() {
    super.onInit();
    bool savedTheme = _box.read(_storageKey) ?? false;
    isDark.value = savedTheme;

    // Apply saved theme at startup
    Get.changeThemeMode(savedTheme ? ThemeMode.dark : ThemeMode.light);
  }

  /// Toggle theme & persist
  void toggleTheme() {
    isDark.value = !isDark.value;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
    _box.write(_storageKey, isDark.value);
  }
}

/// =================================================================
///                        LIGHT THEME
/// =================================================================
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.indigo,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 1,
    centerTitle: true,
  ),
  cardColor: const Color(0xFFF5F6F9),
  iconTheme: const IconThemeData(color: Color(0xFF2181AE)),
  listTileTheme: const ListTileThemeData(
    iconColor: Color(0xFF2181AE),
    textColor: Color(0xFF4B4B4B),
  ),
);

/// =================================================================
///                        DARK THEME
/// =================================================================
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.orange,
  scaffoldBackgroundColor: const Color(0xFF0B0E13),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0B0E13),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  cardColor: Colors.white24,
  iconTheme: const IconThemeData(color: Colors.orangeAccent),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.orangeAccent,
    textColor: Colors.white,
  ),
);
