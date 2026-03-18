// lib/core/themes/app_theme.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
// NOTE: Replace 'velox_partner_app' with your actual package name (found in pubspec.yaml)

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Global Settings
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto', // Use Roboto or add a custom font in pubspec.yaml

      // 1. Core ColorScheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
      ),

      // 2. AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.appbar,
        foregroundColor: AppColors.textPrimary,
        elevation: 0, // Using minimal elevation for a modern look
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // 3. Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        labelLarge: TextStyle(fontWeight: FontWeight.bold),
      ),

      // 4. Input Field Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.greyLight, width: 1),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.grey),
      ),

      // 5. Elevated Button Theme (Primary Action)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.white,
          backgroundColor: AppColors.secondary, // Use secondary color for primary action
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      // 6. Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}