import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/Api_Service/Auth/auth_api.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/utils/app_storage.dart';
import '../../../../core/utils/custome_snakbar.dart';
import '../../../../core/utils/device_info_service.dart';
import '../../../../core/utils/full_screen_loader.dart';
import '../../../routes/app_pages.dart';

class OtpverifyscreenController extends GetxController {

  late final String credential;

  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  final RxList<String> otpValues = List.filled(6, '').obs;
  final focusedIndex = 0.obs;

  // ── State ──────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isOtpComplete = false.obs;

  // ── Resend Timer ───────────────────────────────────────────────────────────
  final timer = 60.obs;
  final canResend = false.obs;
  final isResending = false.obs;
  Timer? _countdownTimer;

  // ── Init ───────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    credential = Get.arguments?['credential'] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNodes[0].requestFocus();
      focusedIndex.value = 0;
    });

    for (int i = 0; i < 6; i++) {
      focusNodes[i].addListener(() {
        if (focusNodes[i].hasFocus) {
          focusedIndex.value = i;
        }
      });
    }

    startTimer();
  }

  // ── Timer ──────────────────────────────────────────────────────────────────
  void startTimer() {
    timer.value = 60;
    canResend.value = false;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
          (t) {
        if (timer.value == 0) {
          canResend.value = true;
          t.cancel();
        } else {
          timer.value--;
        }
      },
    );
  }

  String get timerDisplay {
    final minutes = (timer.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (timer.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // ── OTP Input ──────────────────────────────────────────────────────────────
  void onOtpChanged(String value, int index) {
    if (value.isEmpty) {
      otpValues[index] = '';
      if (index > 0) {
        focusNodes[index - 1].requestFocus();
        otpControllers[index - 1].selection = TextSelection.fromPosition(
          TextPosition(offset: otpControllers[index - 1].text.length),
        );
      }
    } else {
      otpValues[index] = value;
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
    }
    _checkOtpComplete();
  }

  void _checkOtpComplete() {
    isOtpComplete.value = otpValues.every((v) => v.isNotEmpty);
  }

  String get _fullOtp => otpValues.join();

  // ── Resend OTP ─────────────────────────────────────────────────────────────
  Future<void> resendOtp() async {
    if (!canResend.value || isResending.value) return;

    try {
      isResending.value = true;

      final response = await ApiAuth.resendWorkerLoginOtp(
        endpoint: ApiUrl.loginresendotp,
        body: {
          "credential": credential,
        },
      );

      debugPrint("WORKER RESEND OTP RESPONSE ::: $response");

      if (response['success'] == true) {
        // OTP field clear
        for (int i = 0; i < 6; i++) {
          otpControllers[i].clear();
          otpValues[i] = '';
        }
        isOtpComplete.value = false;

        // Message extract — nested map handle
        final messageMap = response['message'];
        final displayMessage = messageMap is Map
            ? messageMap['message']?.toString() ?? "OTP sent successfully"
            : messageMap?.toString() ?? "OTP sent successfully";

        CustomSnackbar.showSuccess("OTP Resent", displayMessage);
        startTimer();

      } else {
        final messageMap = response['message'];
        final errorMessage = messageMap is String
            ? messageMap
            : "Failed to resend OTP";

        CustomSnackbar.showError("Resend Failed", errorMessage);
      }
    } catch (e) {
      debugPrint("WORKER RESEND OTP ERROR ::: $e");
      CustomSnackbar.showError("Error", "Something went wrong. Please try again");
    } finally {
      isResending.value = false;
    }
  }

  // ── Verify OTP ─────────────────────────────────────────────────────────────
  Future<void> verifyOtp() async {
    try {
      if (!isOtpComplete.value) return;

      FullScreenLoader.show(message: "Verifying OTP...");

      if (!DeviceInfoService.isReady) {
        await DeviceInfoService.fetchDeviceInfo();
      }

      final response = await ApiAuth.loginThroughOtpVerify(
        endpoint: ApiUrl.LoginOtpVerify,
        xDeviceID: DeviceInfoService.deviceId!,
        xDeviceType: DeviceInfoService.deviceType ?? '',
        xDeviceName: DeviceInfoService.deviceName ?? '',
        xDeviceOsVersion: DeviceInfoService.osVersion ?? '',
        body: {
          "credential": credential,
          "otp": _fullOtp,
        },
      );

      FullScreenLoader.hide();

      debugPrint("OTP VERIFY RESPONSE ::: $response");

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

      _handleError(response);

    } catch (e, stack) {
      FullScreenLoader.hide();
      debugPrint("OTP VERIFY ERROR ::: $e");
      debugPrint("STACK TRACE ::: $stack");
      CustomSnackbar.showError("Error", "Something went wrong");
    }
  }

  void _handleError(dynamic response) {
    String errorMessage = "OTP verification failed";
    final message = response['message'];

    if (message is String) {
      errorMessage = message;
    } else if (message is Map) {
      final first = (message['otp'] ?? message['credential']);
      if (first is List && first.isNotEmpty) {
        errorMessage = first[0].toString();
      }
    }

    CustomSnackbar.showError("Failed", errorMessage);
  }

  // ── Dispose ────────────────────────────────────────────────────────────────
  @override
  void onClose() {
    _countdownTimer?.cancel();
    for (final c in otpControllers) c.dispose();
    for (final f in focusNodes) f.dispose();
    super.onClose();
  }
}