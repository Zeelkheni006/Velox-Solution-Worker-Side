import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/Api_Service/Auth/auth_api.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/utils/app_storage.dart';
import '../../../../core/utils/custome_snakbar.dart';
import '../../../../core/utils/device_info_service.dart';
import '../../../../core/utils/full_screen_loader.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final credentialController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPhoneNumber = false.obs;

  final isCredentialFilled = false.obs;

  // ================= INIT =================
  @override
  void onInit() {
    super.onInit();
    DeviceInfoService.fetchDeviceInfo();

    credentialController.addListener(() {
      _phoneInputLimiter();

      isCredentialFilled.value =
          credentialController.text.trim().isNotEmpty;
    });
  }

  // ================= INPUT TYPE =================
  void checkInputType(String value) {
    isPhoneNumber.value =
        RegExp(r'^[0-9+ ]+$').hasMatch(value.replaceAll(' ', ''));
  }

  // ================= PHONE LIMITER =================
  void _phoneInputLimiter() {
    String text = credentialController.text.replaceAll(' ', '');

    if (text.isEmpty) return;

    // apply only when digits or +
    if (!RegExp(r'^[0-9+]+$').hasMatch(text)) return;

    String updatedText = text;

    // + only at first position
    if (updatedText.contains('+') && !updatedText.startsWith('+')) {
      updatedText = updatedText.replaceAll('+', '');
    }

    // case 1: +91XXXXXXXXXX
    if (updatedText.startsWith('+91')) {
      if (updatedText.length > 13) {
        updatedText = updatedText.substring(0, 13);
      }
    }
    // case 2: normal 10 digit number
    else {
      String onlyNumbers = updatedText.replaceAll('+', '');
      if (onlyNumbers.length > 10) {
        updatedText = onlyNumbers.substring(0, 10);
      }
    }

    if (updatedText != credentialController.text) {
      credentialController.text = updatedText;
      credentialController.selection = TextSelection.fromPosition(
        TextPosition(offset: updatedText.length),
      );
    }
  }

  // 🔥 always returns +91XXXXXXXXXX if phone
  String getFormattedCredential() {
    String value = credentialController.text.trim().replaceAll(' ', '');

    if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
      if (!value.startsWith('+91')) {
        value = "+91$value";
      }
    }
    return value;
  }

  // ================= VALIDATION =================
  bool validateLoginForm() {
    final credential = credentialController.text.trim();
    final password = passwordController.text.trim();

    if (credential.isEmpty) {
      CustomSnackbar.showWarning("Required", "Please enter email or phone");
      return false;
    }

    if (password.isEmpty) {
      CustomSnackbar.showWarning("Required", "Please enter password");
      return false;
    }

    if (!formKey.currentState!.validate()) {
      CustomSnackbar.showWarning("Invalid", "Please enter valid details");
      return false;
    }

    return true;
  }

  // ================= PASSWORD LOGIN FLOW =================
  Future<void> loginWithPassword() async {
    try {
      if (!validateLoginForm()) return;

      FullScreenLoader.show();

      if (!DeviceInfoService.isReady) {
        await DeviceInfoService.fetchDeviceInfo();
      }

      final formattedCredential = getFormattedCredential();

      final initiateResponse = await ApiAuth.loginInitiate(
        endpoint: ApiUrl.LoginInitiate,
        xDeviceID: DeviceInfoService.deviceId!,
        xDeviceType: DeviceInfoService.deviceType ?? '',
        xDeviceName: DeviceInfoService.deviceName ?? '',
        xDeviceOsVersion: DeviceInfoService.osVersion ?? '',
        body: {
          "credential": formattedCredential,
        },
      );

      if (initiateResponse['success'] != true) {
        FullScreenLoader.hide();
        CustomSnackbar.showError(
          "Login Failed",
          (initiateResponse['message']['credential'] as List?)?.first ?? "User not found",
        );
        return;
      }

      final response = await ApiAuth.loginWithPassword(
        endpoint: ApiUrl.LoginPassword,
        xDeviceID: DeviceInfoService.deviceId!,
        xDeviceType: DeviceInfoService.deviceType ?? '',
        xDeviceName: DeviceInfoService.deviceName ?? '',
        xDeviceOsVersion: DeviceInfoService.osVersion ?? '',
        body: {
          "credential": formattedCredential,
          "password": passwordController.text.trim(),
        },
      );

      print("LOGIN THROUGH PASSWORD ::: $response");

      FullScreenLoader.hide();

      if (response['success'] == true) {
        final data = response['data'] ?? {};

        await AppStorage.saveWorkerAuthData(
          accessToken: data['worker_access_token']?.toString() ?? '',
          refreshToken: data['worker_refresh_token']?.toString() ?? '',
          workerId: int.tryParse(data['worker_id']?.toString() ?? '0') ?? 0,
        );

        CustomSnackbar.showSuccess("Success", "Login successful");
        Get.offAllNamed(Routes.DASHBOARD);
        return;
      }

      _handleLoginError(response);
    } catch (e, stack) {
      FullScreenLoader.hide();
      debugPrint("LOGIN ERROR ::: $e");
      debugPrint("STACK TRACE ::: $stack");
      CustomSnackbar.showError("Error", "Something went wrong");
    }
  }

  // ================= OTP LOGIN =================
  Future<void> loginWithOTP() async {
    try {
      final credential = credentialController.text.trim();

      if (credential.isEmpty) {
        CustomSnackbar.showWarning("Required", "Enter email or phone");
        return;
      }

      FullScreenLoader.show(message: "Sending OTP...");

      if (!DeviceInfoService.isReady) {
        await DeviceInfoService.fetchDeviceInfo();
      }

      final formattedCredential = getFormattedCredential();

      final response = await ApiAuth.loginWithPassword(
        endpoint: ApiUrl.LoginOtp,
        xDeviceID: DeviceInfoService.deviceId!,
        xDeviceType: DeviceInfoService.deviceType ?? '',
        xDeviceName: DeviceInfoService.deviceName ?? '',
        xDeviceOsVersion: DeviceInfoService.osVersion ?? '',
        body: {
          "credential": formattedCredential,
        },
      );

      print("LOGIN WITH OTP ::: $response");

      FullScreenLoader.hide();

      if (response['success'] == true) {
        final responseMessage = response['message'];

        final msg = (responseMessage is Map)
            ? responseMessage['message']?.toString()
            : responseMessage?.toString();

        CustomSnackbar.showSuccess(
          "OTP Sent",
          msg ?? "Please check your phone/email",
        );
        Get.toNamed(Routes.OTPVERIFYSCREEN, arguments: {'credential': formattedCredential});
        return;
      }

      _handleLoginError(response);
    } catch (e, stack) {
      // ✅ Hide Loader (IMPORTANT in catch)
      FullScreenLoader.hide();

      debugPrint("LOGIN WITH OTP ERROR ::: $e");
      debugPrint("STACK TRACE ::: $stack");

      CustomSnackbar.showError(
        "Oops!",
        "Something went wrong. Please try again",
      );
    }
  }

  // ================= ERROR HANDLER =================
  void _handleLoginError(dynamic response) {
    String errorMessage = "Login failed";
    final message = response['message'];

    if (message is String) {
      errorMessage = message;
    } else if (message is Map &&
        message['credential'] is List &&
        message['credential'].isNotEmpty) {
      errorMessage = message['credential'][0].toString();
    }

    CustomSnackbar.showError("Login Failed", errorMessage);
  }

  // ================= DISPOSE =================
  @override
  void onClose() {
    credentialController.removeListener(_phoneInputLimiter);
    super.onClose();
  }
}
