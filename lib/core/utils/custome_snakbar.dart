import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_text_styles.dart';

class CustomSnackbar {
  // ERROR Message
  static void showError(String title, String message) {
    Get.snackbar(
      "",
      "",
      backgroundColor: AppColors.error,
      snackPosition: SnackPosition.TOP,
      borderRadius: AppRadii.md(Get.context!).x,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      titleText: Text(
        title,
        style: AppTextStyles.buttonMedium(Get.context!).copyWith(
          color: AppColors.white,
        ),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.bodyMedium(Get.context!).copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }

  // SUCCESS Message
  static void showSuccess(String title, String message) {
    Get.snackbar(
      "",
      "",
      backgroundColor: AppColors.primary,
      snackPosition: SnackPosition.TOP,
      borderRadius: AppRadii.md(Get.context!).x,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      titleText: Text(
        title,
        style: AppTextStyles.buttonMedium(Get.context!).copyWith(
          color: AppColors.white,
        ),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.bodyMedium(Get.context!).copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }

  // WARNING Message
  static void showWarning(String title, String message) {
    Get.snackbar(
      "",
      "",
      backgroundColor: AppColors.warning,
      snackPosition: SnackPosition.TOP,
      borderRadius: AppRadii.md(Get.context!).x,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      titleText: Text(
        title,
        style: AppTextStyles.buttonMedium(Get.context!).copyWith(
          color: AppColors.black,
        ),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.bodyMedium(Get.context!).copyWith(
          color: AppColors.black,
        ),
      ),
    );
  }

  // INFO Message
  static void showInfo(String title, String message) {
    Get.snackbar(
      "",
      "",
      backgroundColor: AppColors.secondary,
      snackPosition: SnackPosition.TOP,
      borderRadius: AppRadii.md(Get.context!).x,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      titleText: Text(
        title,
        style: AppTextStyles.buttonMedium(Get.context!).copyWith(
          color: AppColors.white,
        ),
      ),
      messageText: Text(
        message,
        style: AppTextStyles.bodyMedium(Get.context!).copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }
}