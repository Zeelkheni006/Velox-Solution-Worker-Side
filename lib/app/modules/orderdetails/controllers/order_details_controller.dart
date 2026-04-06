import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/api/Api_Service/Close_Order/close_order.dart';
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

  var capturedImages = RxList<File?>(List.filled(5, null));

  final Map<int, Future<File?>> _compressionFutures = {};
  final Map<int, File?> _compressedCache = {};

  final ImagePicker _picker = ImagePicker();

  bool get allImagesCaptured => capturedCount >= minImageCount;
  int get capturedCount => capturedImages.where((img) => img != null).length;
  int get nextEmptySlot => capturedImages.indexWhere((img) => img == null);

  String get paymentStatus => order.value?.paymentStatus ?? '';
  bool get isPaymentUnpaid => paymentStatus == 'unpaid';

  var orderServiceCompleted = false.obs;
  var orderIsFinal = false.obs;
  String get finalOrderStatus => order.value?.orderStatus ?? '';

  // ── FIX: single flag to prevent duplicate bottom sheet ──
  bool _otpSheetScheduled = false;


  @override
  void onInit() {
    super.onInit();
    print("CURRENT ORDER ID ::: $orderId");
    // ── FIX: run sequentially so checkOtpStateOnLoad runs
    //         AFTER fetchOrderDetails + checkOrderStatus finish ──
    _initPage();
  }

  Future<void> _initPage() async {
    await fetchOrderDetails();
    await checkOrderStatus();
    // ── Only check saved OTP session after API calls complete ──
    await checkOtpStateOnLoad();
  }

  // ============================================================
  // OTP Sheet scheduling — single entry point
  // ============================================================

  /// Call this instead of directly opening the sheet.
  /// Ensures the sheet is opened at most once per page visit.
  void scheduleOtpSheet(BuildContext context) {
    if (_otpSheetScheduled) return;
    if (Get.isBottomSheetOpen == true) return;
    if (isOtpVerified.value) return;

    _otpSheetScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Double-check state is still valid before opening
      if (!isOtpVerified.value && showOtpField.value) {
        // Import and call the view's show method via callback
        _onOpenOtpSheet?.call(context);
      }
      // Reset flag so it can trigger again if sheet was dismissed
      // and showOtpField becomes true again (e.g. resend OTP)
      _otpSheetScheduled = false;
    });
  }

  // Callback set by the View to open the OTP bottom sheet
  void Function(BuildContext context)? _onOpenOtpSheet;

  void setOtpSheetCallback(void Function(BuildContext context) callback) {
    _onOpenOtpSheet = callback;
  }

  // ============================================================
  // Image capture
  // ============================================================

  Future<bool> captureImageAtSlot(int slotIndex) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) return false;

      final originalFile = File(photo.path);

      final list = List<File?>.from(capturedImages);
      list[slotIndex] = originalFile;
      capturedImages.assignAll(list);

      _compressionFutures[slotIndex] =
          _compressInBackground(originalFile, slotIndex);

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

  Future<File?> _compressInBackground(File source, int index) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/order_${orderId}_slot_$index.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        source.path,
        targetPath,
        quality: 75,
        minWidth: 1024,
        minHeight: 768,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      print("COMPRESS ERROR slot $index ::: $e");
      return null;
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

  // ============================================================
  // Complete / Close order
  // ============================================================

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
      if (_compressionFutures.isNotEmpty) {
        await Future.wait(_compressionFutures.values);
      }

      final List<File> uploadImages = [];
      for (int i = 0; i < maxImageCount; i++) {
        if (capturedImages[i] != null) {
          final compressed = _compressedCache[i];
          final original = capturedImages[i]!;
          uploadImages.add(compressed ?? original);
        }
      }

      print("UPLOADING ${uploadImages.length} images:");
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

          if (paymentPending) {
            await fetchOrderDetails();
            orderServiceCompleted(true);
            CustomSnackbar.showSuccess(
              "Service Completed",
              "$mainMessage\nPending Amount: ₹$pendingAmount",
            );
          } else {
            Get.offAllNamed(Routes.DASHBOARD);
            await Future.delayed(const Duration(milliseconds: 300));
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
      CustomSnackbar.showError(
          "Error", "Something went wrong. Please try again.");
    }
  }

  Future<void> closeOrder() async {
    FullScreenLoader.show(message: "Closing order...");

    try {
      final res = await CloseOrder.closeOrder(orderId);

      print("CLOSE ORDER RESPONSE ::: $res");

      FullScreenLoader.hide();

      if (res['success'] == true) {
        Get.offAllNamed(Routes.DASHBOARD);
        await Future.delayed(const Duration(milliseconds: 300));

        final message = res['message'];
        CustomSnackbar.showSuccess(
          "Order Closed",
          message is Map
              ? message['message']?.toString() ?? "Order closed successfully"
              : message?.toString() ?? "Order closed successfully",
        );
      } else {
        final message = res['message'];
        CustomSnackbar.showError(
          "Error",
          message is Map
              ? message['message']?.toString() ?? "Failed to close order"
              : message?.toString() ?? "Failed to close order",
        );
      }
    } catch (e) {
      print("CLOSE ORDER ERROR ::: $e");
      FullScreenLoader.hide();
      CustomSnackbar.showError(
          "Error", "Something went wrong. Please try again.");
    }
  }

  // ============================================================
  // API calls
  // ============================================================

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
      print("ORDER STATUS ::: $res");

      if (res['success'] == true) {
        final otpVerified = res['message']?['otp_verified'] ?? false;
        final orderStatus = res['message']?['order_status'] ?? '';
        final serviceCompleted = orderStatus == 'service_completed';

        if (orderStatus == 'closed' || orderStatus == 'cancelled') {
          orderIsFinal(true);
          isOtpVerified.value = otpVerified;
          return;
        }

        isOtpVerified.value = otpVerified;

        if (serviceCompleted && isPaymentUnpaid) {
          orderServiceCompleted(true);
        }
      }
    } catch (e) {
      print("ORDER STATUS ERROR ::: $e");
    }
  }

  Future<void> sendOtp() async {
    try {
      FullScreenLoader.show(message: "Sending OTP...");
      final res = await SendOtp.verifyUserSendOtp(orderId);
      print("OTP RESPONSE ::: $res");
      if (res['success'] == true) {
        final message = res['message']['message'];
        final expiresIn = res['message']['expires_in'];
        FullScreenLoader.hide();
        CustomSnackbar.showSuccess(
            "Success", message ?? "OTP sent successfully");
        await AppStorage.saveOtpSession(
          orderId: orderId,
          expiresInSeconds: expiresIn,
        );
        startTimer(expiresIn);
        // ── Reset sheet flag so it can open fresh ──
        _otpSheetScheduled = false;
        showOtpField(true);
      } else {
        FullScreenLoader.hide();
        CustomSnackbar.showError(
          "Error",
          res['message']?.toString() ?? "Failed to send OTP",
        );
      }
    } catch (e) {
      FullScreenLoader.hide();
      print("SEND OTP ERROR ::: $e");
      CustomSnackbar.showError(
          "Error", "Something went wrong. Please try again.");
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
      CustomSnackbar.showError(
          "Error", "Something went wrong. Please try again.");
    }
  }

  Future<void> checkOtpStateOnLoad() async {
    final active = await AppStorage.isOtpActive(orderId);
    if (active) {
      final seconds = await AppStorage.getOtpRemainingSeconds();
      if (seconds != null && seconds > 0) {
        startTimer(seconds);
        // ── Reset flag so fresh sheet can open ──
        _otpSheetScheduled = false;
        showOtpField(true);
      } else {
        // Expired session — clean up
        await AppStorage.clearOtpSession();
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
  void onClose() {
    stopTimer();
    otpController.dispose();
    _onOpenOtpSheet = null;
    super.onClose();
  }
}