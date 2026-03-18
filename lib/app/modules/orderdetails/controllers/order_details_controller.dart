import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/api/Api_Service/Order_Status/order_status.dart';
import '../../../../core/api/Api_Service/Send_Otp/send_otp.dart';
import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order.dart';
import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order_model.dart';
import '../../../../core/utils/app_storage.dart';
import '../../../../core/utils/custome_snakbar.dart';
import '../../../routes/app_pages.dart';

class OrderDetailsController extends GetxController {
  final int orderId;
  OrderDetailsController(this.orderId);

  var isLoading = true.obs;
  var order = Rxn<OrderModel>();

  var showOtpField = false.obs;
  var otpController = TextEditingController();

  var remainingSeconds = 0.obs;
  Timer? _timer;

  var isOtpVerified = false.obs;

  var capturedImage = Rxn<File>();

  final ImagePicker _picker = ImagePicker();

  final isBottomSheetOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("CURRENT ORDER ID ::: ${orderId}");
    fetchOrderDetails();
    checkOrderStatus();
    checkOtpStateOnLoad();
  }

  Future<bool> captureImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (photo == null) return false;

      capturedImage.value = File(photo.path);
      return true;
    } catch (e) {
      print("CAPTURE IMAGE ERROR ::: $e");
      CustomSnackbar.showError("Error", "Could not open camera.");
      return false;
    }
  }

  void deleteCapturedImage() {
    capturedImage.value = null;
  }

  Future<void> completeOrder() async {
    final imageFile = capturedImage.value;

    if (imageFile == null) {
      CustomSnackbar.showError("Error", "Please capture an image first.");
      return;
    }

    try {
      isLoading(true);

      final res = await OrderStatus.orderComplete(
        orderId: orderId,
        imageFile: imageFile,
      );

      print("ORDER COMPLETE RESPONSE ::: $res");

      if (res['success'] == true) {

        capturedImage.value = null;

        final messageData = res['message'];

        if (messageData is Map) {

          final String mainMessage = messageData['message'] ?? "Order Completed Successfully";

          final bool paymentPending = messageData['payment_pending'] ?? false;

          final double pendingAmount = (messageData['pending_amount'] ?? 0).toDouble();

          if (paymentPending) {
            Get.offAllNamed(Routes.DASHBOARD);
            await Future.delayed(const Duration(milliseconds: 500));
            CustomSnackbar.showSuccess(
              "Service Completed",
              "$mainMessage\nPending Amount : ₹$pendingAmount",
            );
          } else {
            Get.offAllNamed(Routes.DASHBOARD);
            await Future.delayed(const Duration(milliseconds: 500));
            CustomSnackbar.showSuccess(
              "Success",
              mainMessage,
            );
          }

        } else {
          Get.offAllNamed(Routes.DASHBOARD);
          await Future.delayed(const Duration(milliseconds: 500));
          CustomSnackbar.showSuccess(
            "Success",
            messageData?.toString() ?? "Order Completed Successfully",
          );
        }

      } else {
        CustomSnackbar.showError(
          "Error",
          res['message']?.toString() ?? "Failed to complete order",
        );
      }

    } catch (e) {
      print("COMPLETE ORDER ERROR ::: $e");

      CustomSnackbar.showError(
        "Error",
        "Something went wrong. Please try again.",
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchOrderDetails() async {
    try {
      isLoading(true);
      final response = await OrderApi.getOrderDetails(orderId);

      print("ORDER DETIALS RESPONSE ::: ${response}");

      if (response['success'] == true && response['data'] != null) {
        order.value = OrderModel.fromJson(response['data']);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> checkOrderStatus() async {
    try {
      final res = await OrderStatus.workerOrderStatus(orderId);

      if (res['success'] == true) {
        final otpVerified = res['message']?['otp_verified'] ?? false;
        isOtpVerified.value = otpVerified;
        print("OTP VERIFIED STATUS ::: $otpVerified");
      }
    } catch (e) {
      print("ORDER STATUS ERROR ::: $e");
    }
  }

  Future<void> sendOtp() async {
    try {
      final res = await SendOtp.verifyUserSendOtp(orderId);
      print("OTP RESPONSE ::: $res");

      if (res['success'] == true) {
        final message = res['message']['message'];
        final expiresIn = res['message']['expires_in'];

        CustomSnackbar.showSuccess("Success", message ?? "OTP sent successfully");

        await AppStorage.saveOtpSession(
          orderId: orderId,
          expiresInSeconds: expiresIn,
        );

        startTimer(expiresIn);
        showOtpField(true);
      } else {
        CustomSnackbar.showError(
          "Error",
          res['message']?.toString() ?? "Failed to send OTP",
        );
      }
    } catch (e) {
      print("SEND OTP ERROR ::: $e");
      CustomSnackbar.showError("Error", "Something went wrong. Please try again.");
    }
  }

  Future<void> confirmOtp() async {
    try {
      final res = await SendOtp.verifyConfirmOtp(
        orderId,
        otpController.text.trim(),
      );

      print("CONFIRM OTP RESPONSE ::: $res");

      if (res['success'] == true) {
        isOtpVerified.value = true;
        await AppStorage.clearOtpSession();
        otpController.clear();
        stopTimer();
        showOtpField(false);

        // ✅ DON'T use Get.back() or Navigator.pop here
        // Let the bottom sheet close itself through the UI

        // Show success message after a slight delay
        Future.delayed(const Duration(milliseconds: 500), () {
          CustomSnackbar.showSuccess(
            "Success",
            res['message'] is Map
                ? res['message']['message'] ?? "OTP Verified Successfully"
                : res['message'].toString(),
          );
        });
      } else {
        CustomSnackbar.showError(
          "Error",
          res['message']?.toString() ?? "Invalid or expired OTP",
        );
      }
    } catch (e) {
      print("CONFIRM OTP ERROR ::: $e");
      CustomSnackbar.showError("Error", "Something went wrong. Please try again.");
    }
  }

  Future<void> checkOtpStateOnLoad() async {
    final active = await AppStorage.isOtpActive(orderId);
    if (active) {
      final seconds = await AppStorage.getOtpRemainingSeconds();
      if (seconds != null) {
        startTimer(seconds);
        showOtpField(true);
      }
    }
  }

  void startTimer(int seconds) {
    remainingSeconds.value = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value <= 1) {
        stopTimer();
        remainingSeconds.value = 0;
        showOtpField(false);
        AppStorage.clearOtpSession();

        // ✅ DON'T use Get.back() or Navigator.pop here
        // Let the bottom sheet close itself through the UI

        if (Get.isDialogOpen == true) Get.back();
      } else {
        remainingSeconds.value--;
      }
    });
  }

  void _forceCloseBottomSheet() {
    try {
      // Method 1: Using GetX
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      // Method 2: Using Navigator (more reliable)
      if (Get.overlayContext != null) {
        Navigator.of(Get.overlayContext!, rootNavigator: true).pop();
      }

      // Method 3: Using custom observable
      isBottomSheetOpen.value = false;

    } catch (e) {
      print("Error closing bottom sheet: $e");
    }
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void onClose() {
    stopTimer();
    otpController.dispose();
    super.onClose();
  }
}