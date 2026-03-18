import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/api/Api_Service/Order_Status/order_status.dart';
import '../../../../core/api/Api_Service/Send_Otp/send_otp.dart';
import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order.dart';
import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order_model.dart';
import '../../../../core/utils/app_storage.dart';
import '../../../../core/utils/custome_snakbar.dart';
import '../../../../core/utils/full_screen_loader.dart';
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

  static const int maxImageCount = 5;
  static const int minImageCount = 1;

  // UI preview mate (original full quality)
  var capturedImages = RxList<File?>(List.filled(5, null));

  // Background compressed files store karvani map
  // Key = slot index, Value = Future<compressed File>
  final Map<int, Future<File?>> _compressionFutures = {};
  final Map<int, File?> _compressedCache = {};

  final ImagePicker _picker = ImagePicker();

  // ── Helpers ──────────────────────────────────────────────────────────────

  bool get allImagesCaptured => capturedCount >= minImageCount;
  int get capturedCount => capturedImages.where((img) => img != null).length;
  int get nextEmptySlot => capturedImages.indexWhere((img) => img == null);

  // ── STEP 1: Photo le tyare INSTANTLY preview show karo + background compress ─

  Future<bool> captureImageAtSlot(int slotIndex) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,           // Full quality for preview
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) return false;

      final originalFile = File(photo.path);

      // Instantly update UI with original (zero delay for user)
      final list = List<File?>.from(capturedImages);
      list[slotIndex] = originalFile;
      capturedImages.assignAll(list);

      // Start compression in background — user next photo capture kare tyare
      // background ma compress thai jay
      _compressionFutures[slotIndex] = _compressInBackground(
        originalFile,
        slotIndex,
      );

      // Cache result jyare ready thay
      _compressionFutures[slotIndex]!.then((compressed) {
        if (compressed != null) {
          _compressedCache[slotIndex] = compressed;
          print(
            "✅ Slot $slotIndex compressed: "
                "${originalFile.lengthSync()} → ${compressed.lengthSync()} bytes "
                "(${((1 - compressed.lengthSync() / originalFile.lengthSync()) * 100).toStringAsFixed(0)}% smaller)",
          );
        }
      });

      return true;
    } catch (e) {
      print("CAPTURE IMAGE ERROR ::: $e");
      CustomSnackbar.showError("Error", "Could not open camera.");
      return false;
    }
  }

  // ── Background compression (runs while user is busy with other slots) ─────

  Future<File?> _compressInBackground(File source, int index) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/order_${orderId}_slot_$index.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        source.path,
        targetPath,
        quality: 75,         // 75% = visually good, ~200–400KB per photo
        minWidth: 1024,
        minHeight: 768,
        format: CompressFormat.jpeg,
        keepExif: false,     // Strip EXIF = faster upload + privacy
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      print("COMPRESS ERROR slot $index ::: $e");
      return null; // Original fallback
    }
  }

  Future<bool> captureNextImage() async {
    final slot = nextEmptySlot;
    if (slot == -1) return false;
    return captureImageAtSlot(slot);
  }

  void deleteImageAtSlot(int slotIndex) {
    _compressionFutures.remove(slotIndex);
    _compressedCache.remove(slotIndex);

    final list = List<File?>.from(capturedImages);
    list[slotIndex] = null;
    capturedImages.assignAll(list);
  }

  void clearAllImages() {
    _compressionFutures.clear();
    _compressedCache.clear();
    capturedImages.assignAll(List.filled(maxImageCount, null));
  }

  // ── STEP 2: Complete Order ─────────────────────────────────────────────────
  // Pending compressions wait karo (usually 0ms if user took even 2-3 sec)
  // Pachhi compressed files upload karo

  Future<void> completeOrder() async {
    final originalImages = capturedImages.whereType<File>().toList();

    if (originalImages.length < minImageCount) {
      CustomSnackbar.showError(
        "Incomplete",
        "Please capture at least $minImageCount photo before completing.",
      );
      return;
    }

    FullScreenLoader.show(message: "Uploading photos...");

    try {
      // Koi compression pending hoy to wait karo
      // (mostly 0ms — user typically 2-3 sec lagave cho between photos)
      if (_compressionFutures.isNotEmpty) {
        await Future.wait(_compressionFutures.values);
      }

      // Compressed version use karo, na hoy to original
      final List<File> uploadImages = [];
      for (int i = 0; i < maxImageCount; i++) {
        if (capturedImages[i] != null) {
          final compressed = _compressedCache[i];
          final original = capturedImages[i]!;
          uploadImages.add(compressed ?? original);
        }
      }

      // Log sizes for debugging
      print("📤 UPLOADING ${uploadImages.length} images:");
      uploadImages.asMap().forEach((i, f) {
        print("  Slot $i: ${(f.lengthSync() / 1024).toStringAsFixed(0)} KB");
      });

      final res = await OrderStatus.orderComplete(
        orderId: orderId,
        imageFiles: uploadImages,
      );

      print("ORDER COMPLETE RESPONSE ::: $res");

      FullScreenLoader.hide();

      if (res['success'] == true) {
        clearAllImages();

        final messageData = res['message'];

        if (messageData is Map) {
          final String mainMessage =
              messageData['message'] ?? "Order Completed Successfully";
          final bool paymentPending =
              messageData['payment_pending'] ?? false;
          final double pendingAmount =
          (messageData['pending_amount'] ?? 0).toDouble();

          Get.offAllNamed(Routes.DASHBOARD);
          await Future.delayed(const Duration(milliseconds: 300));

          if (paymentPending) {
            CustomSnackbar.showSuccess(
              "Service Completed",
              "$mainMessage\nPending Amount : ₹$pendingAmount",
            );
          } else {
            CustomSnackbar.showSuccess("Success", mainMessage);
          }
        } else {
          Get.offAllNamed(Routes.DASHBOARD);
          await Future.delayed(const Duration(milliseconds: 300));
          CustomSnackbar.showSuccess(
            "Success",
            messageData?.toString() ?? "Order Completed Successfully",
          );
        }
      } else {
        final message = res['message'];
        String errorMessage = "Failed to complete order";

        if (message is Map) {
          if (message.containsKey('images') && message['images'] is List) {
            errorMessage = message['images'][0];
          } else {
            errorMessage = message.toString();
          }
        } else if (message is String) {
          errorMessage = message;
        }

        CustomSnackbar.showError("Error", errorMessage);
      }
    } catch (e) {
      print("COMPLETE ORDER ERROR ::: $e");
      FullScreenLoader.hide();
      CustomSnackbar.showError("Error", "Something went wrong. Please try again.");
    }
  }

  // ── Order Details ─────────────────────────────────────────────────────────

  Future<void> fetchOrderDetails() async {
    try {
      isLoading(true);
      final response = await OrderApi.getOrderDetails(orderId);
      print("ORDER DETAILS RESPONSE ::: $response");
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
      }
    } catch (e) {
      print("ORDER STATUS ERROR ::: $e");
    }
  }

  // ── OTP ───────────────────────────────────────────────────────────────────

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
        if (Get.isDialogOpen == true) Get.back();
      } else {
        remainingSeconds.value--;
      }
    });
  }

  void stopTimer() => _timer?.cancel();

  @override
  void onInit() {
    super.onInit();
    print("CURRENT ORDER ID ::: $orderId");
    fetchOrderDetails();
    checkOrderStatus();
    checkOtpStateOnLoad();
  }

  @override
  void onClose() {
    stopTimer();
    otpController.dispose();
    super.onClose();
  }
}