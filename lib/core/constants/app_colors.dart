import 'package:apilearning/core/constants/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  // Private constructor
  AppColors._();

  // ── Detect current brightness ──
  static bool get _isDark {
    final ctrl = Get.find<ThemeController>();
    return ctrl.isCurrentlyDark;
  }

  // ── PRIMARY ──
  static Color get primary => _isDark ? const Color(0xFFF1F2ED) : const Color(0xFF373328);

  static Color get secondary => _isDark ? const Color(0xFFFF9A40) : const Color(0xFFFF7400);

  // ── APP BAR ──
  static Color get appbar => _isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF1F2ED);

  // ── NEUTRALS ──
  static Color get black => _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

  static Color get white => _isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);

  static Color get grey => _isDark ? const Color(0xFF8E8E93) : const Color(0xFF9E9E9E);

  static Color get greyLight => _isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE0E0E0);

  static Color get greyDark => _isDark ? const Color(0xFFAEAEB2) : const Color(0xFF616161);

  // ── SEMANTIC ──
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error   = Color(0xFFF44336);

  // ── BACKGROUND & SURFACE ──
  static Color get background => _isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

  static Color get surface => _isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F9F9);

  // ── TEXT ──
  static Color get textPrimary => _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1A1D1F);

  static Color get textSecondary => _isDark ? const Color(0xFFAEAEB2) : const Color(0xFF535763);

  static Color get textDisabled => _isDark ? const Color(0xFF636366) : const Color(0xFF9E9E9E);

  static const Color textWhite = Color(0xFFFFFFFF);

  // ── BORDER ──
  static Color get border => _isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE3E3E3);

  static Color get borderDark => _isDark ? const Color(0xFFF1F2ED) : const Color(0xFF373328);
}