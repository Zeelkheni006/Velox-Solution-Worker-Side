import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _key = 'app_theme_mode';

  // 'light' | 'dark' | 'system'
  final RxString themeMode = 'system'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key) ?? 'system';
    themeMode.value = saved;
    _applyTheme(saved);
  }

  Future<void> setTheme(String mode) async {
    themeMode.value = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode);

    Get.changeThemeMode(_resolve(mode));

    Get.forceAppUpdate();
  }

  void _applyTheme(String mode) {
    switch (mode) {
      case 'light':
        Get.changeThemeMode(ThemeMode.light);
        break;
      case 'dark':
        Get.changeThemeMode(ThemeMode.dark);
        break;
      case 'system':
      default:
        Get.changeThemeMode(ThemeMode.system);
        break;
    }
  }

  // Helper — current effective brightness
  bool get isCurrentlyDark {
    if (themeMode.value == 'dark') return true;
    if (themeMode.value == 'light') return false;
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  ThemeMode _resolve(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}