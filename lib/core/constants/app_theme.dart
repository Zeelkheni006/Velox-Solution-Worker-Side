import 'package:flutter/material.dart';
import 'package:apilearning/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.appbar,
      elevation: 0,
      scrolledUnderElevation: 0, // ⭐ ADD THIS
      surfaceTintColor: Colors.transparent, // ⭐ ADD THIS
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.black),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    dividerColor: AppColors.border,
    cardColor: AppColors.white,
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.appbar,
      elevation: 0,
      scrolledUnderElevation: 0, // ⭐ ADD THIS
      surfaceTintColor: Colors.transparent, // ⭐ ADD THIS
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.black),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    dividerColor: AppColors.border,
    cardColor: AppColors.surface,
  );
}