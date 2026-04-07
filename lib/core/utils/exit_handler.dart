import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_text_styles.dart';
import 'app_responsive.dart';
import 'custom_container.dart';
import '../constants/app_assets.dart';

class ExitHandler {
  static DateTime? _lastBackPressTime;

  /// Returns true if the app should exit, false otherwise.
  /// Call this when you're on the "last" screen / tab.
  static Future<bool> onWillExit(BuildContext context) async {
    final now = DateTime.now();

    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 3)) {
      _lastBackPressTime = now;
      _showExitSnackbar(context);
      return false;
    }

    return true;
  }

  static void _showExitSnackbar(BuildContext context) {
    if (Get.isSnackbarOpen) return;

    Get.rawSnackbar(
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.only(
        bottom: rs(context, 72),
        left: rs(context, 40),
        right: rs(context, 40),
      ),
      duration: const Duration(seconds: 3),
      messageText: Center(
        child: CustomContainer(
          padding: EdgeInsets.symmetric(
            horizontal: rs(context, 16),
            vertical: rs(context, 12),
          ),
          backgroundColor: AppColors.primary,
          borderRadius: BorderRadius.all(AppRadii.md_lg(context)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(AppRadii.sm(context)),
                child: Image.asset(
                  AppAssets.logo,
                  height: rs(context, 24),
                  width: rs(context, 24),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: rs(context, 10)),
              Text(
                'Press back again to exit',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}