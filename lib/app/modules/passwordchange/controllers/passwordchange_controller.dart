import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_service/Profile/profile.dart';
import '../../../../core/utils/app_storage.dart';
import '../../../../core/utils/custome_snakbar.dart';

class PasswordchangeController extends GetxController {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;

  bool get isConfirmPasswordValid =>
      confirmPasswordController.text.trim() ==
          newPasswordController.text.trim();

  bool get showPasswordMismatch =>
      confirmPasswordController.text.isNotEmpty &&
          !isConfirmPasswordValid;

  @override
  void onInit() {
    super.onInit();
    confirmPasswordController.addListener(() {});
    newPasswordController.addListener(() {});
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void savePassword() {
    if (isLoading.value) return;

    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      CustomSnackbar.showError("Error", "Please fill all fields");
      return;
    }

    if (!isConfirmPasswordValid) {
      CustomSnackbar.showError("Mismatch", "Passwords do not match");
      return;
    }

    getPasswordChange();
  }

  Future<void> getPasswordChange() async {
    try {
      isLoading.value = true;

      final token = await AppStorage.getWorkerAccessToken();
      if (token == null) {
        CustomSnackbar.showWarning(
          "Session Expired",
          "Please login again",
        );
        return;
      }

      final response = await ProfileApi.changePassword(
        token: token,
        oldPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );

      if (response['success'] == true) {

        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        Get.back();

        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess(
            "Success",
            response['message'] ?? "Password changed successfully",
          );
        });

      } else {
        CustomSnackbar.showError(
          "Error",
          response['message'] ?? "Something went wrong",
        );
      }
    } catch (e) {
      CustomSnackbar.showError("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
