import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../../../../core/utils/custome_snakbar.dart';
import '../../../../core/utils/map_navigation_page.dart';
import '../controllers/order_details_controller.dart';

class OrderDetailsPage extends StatelessWidget {
  final int orderId;
  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return GetX<OrderDetailsController>(
      init: OrderDetailsController(orderId),
      builder: (controller) {
        if (controller.isLoading.value) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final order = controller.order.value;
        if (order == null) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: Center(
              child: Text(
                "Order not found",
                style: AppTextStyles.bodyLarge(context)
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        final contact = order.contact;
        final address = order.address;

        final bool canCall =
            contact?.phone != null && contact!.phone!.isNotEmpty;
        final String phoneText = canCall
            ? contact.phone!
            : contact?.message ?? "Phone number not available";
        final String cleanPhone = canCall
            ? contact.phone!.replaceAll(RegExp(r'[^0-9+]'), '')
            : "";
        final bool canNavigate =
            address?.latitude != null && address?.longitude != null;
        final String addressText = canNavigate
            ? address!.formattedAddress!
            : address?.message ?? "Address not available";
        final bool canVerifyUser = canCall && canNavigate;

        return Scaffold(
          backgroundColor: AppColors.surface,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: AppColors.appbar,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              "Order Details",
              style: AppTextStyles.heading4(context),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: rs(context, 20),
                color: AppColors.textPrimary,
              ),
              onPressed: Get.back,
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: rs(context, 90)),
                  child: Column(
                    children: [
                      // ── Hero Header ─────────────────────────────────────
                      CustomContainer(
                        width: double.infinity,
                        padding: EdgeInsets.all(rs(context, 16)),
                        backgroundColor: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(rs(context, 24)),
                          bottomRight: Radius.circular(rs(context, 24)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _infoCard(
                                context,
                                icon: Icons.schedule_rounded,
                                label: "Time Slot",
                                value:
                                order.slotTime.split(' - ').first.trim(),
                              ),
                            ),
                            SizedBox(width: rs(context, 10)),
                            Expanded(
                              child: _infoCard(
                                context,
                                icon: Icons.calendar_month_rounded,
                                label: "Service Date",
                                value: order.serviceDate,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: rs(context, 20)),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: rs(context, 16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _section(
                              context,
                              title: "Payment Status",
                              icon: Icons.payment_rounded,
                              child: _paymentCard(context, order),
                            ),
                            SizedBox(height: rs(context, 20)),
                            _section(
                              context,
                              title: "Customer Contact",
                              icon: Icons.person_rounded,
                              child: _contactCard(
                                  context, phoneText, cleanPhone, canCall),
                            ),
                            SizedBox(height: rs(context, 20)),
                            _section(
                              context,
                              title: "Service Location",
                              icon: Icons.location_on_rounded,
                              child: _locationCard(
                                  context, addressText, canNavigate, address),
                            ),
                            SizedBox(height: rs(context, 24)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Obx(() {
                if (controller.orderIsFinal.value) {
                  final isCancelled = controller.finalOrderStatus == 'cancelled';
                  return Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CustomContainer(
                      padding: EdgeInsets.all(rs(context, 16)),
                      backgroundColor: AppColors.surface,
                      borderRadius: AppRadii.button(context),
                      child: CustomContainer(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: rs(context, 14)),
                        backgroundColor: isCancelled
                            ? AppColors.error.withOpacity(0.12)
                            : AppColors.success.withOpacity(0.12),
                        borderRadius: AppRadii.button(context),
                        border: Border.all(
                          color: isCancelled
                              ? AppColors.error.withOpacity(0.4)
                              : AppColors.success.withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isCancelled
                                  ? Icons.cancel_outlined
                                  : Icons.check_circle_outline_rounded,
                              color: isCancelled ? AppColors.error : AppColors.success,
                            ),
                            SizedBox(width: rs(context, 8)),
                            Text(
                              isCancelled ? "Order Cancelled" : "Order Closed",
                              style: AppTextStyles.buttonMedium(context).copyWith(
                                fontWeight: FontWeight.w700,
                                color: isCancelled ? AppColors.error : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (controller.orderServiceCompleted.value && controller.isPaymentUnpaid) {
                  return Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CustomContainer(
                      padding: EdgeInsets.all(rs(context, 16)),
                      backgroundColor: AppColors.surface,
                      borderRadius: AppRadii.button(context),
                      child: GestureDetector(
                        onTap: () => controller.closeOrder(),
                        child: _closeOrderButton(context),
                      ),
                    ),
                  );
                }

                if (controller.isOtpVerified.value) {
                  return Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CustomContainer(
                      padding: EdgeInsets.all(rs(context, 16)),
                      backgroundColor: AppColors.surface,
                      borderRadius: AppRadii.button(context),
                      onTap: () =>
                          _showImageCaptureBottomSheet(context, controller),
                      child: _actionButton(
                        context,
                        controller.allImagesCaptured
                            ? Icons.check_circle
                            : Icons.camera_alt_rounded,
                        controller.allImagesCaptured
                            ? "Complete Order"
                            : controller.capturedCount > 0
                            ? "Photos ${controller.capturedCount}/5 — Continue"
                            : "Capture Order Photos",
                      ),
                    ),
                  );
                }

                // ── OTP sheet open — button hide ───────────────────────
                if (controller.showOtpField.value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!(Get.isBottomSheetOpen == true) &&
                        !controller.isOtpVerified.value) {
                      _showOtpBottomSheet(context, controller);
                    }
                  });
                  return const SizedBox.shrink();
                }

                // ── VERIFY USER button ─────────────────────────────────
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: CustomContainer(
                    padding: EdgeInsets.all(rs(context, 16)),
                    backgroundColor: AppColors.surface,
                    borderRadius: AppRadii.button(context),
                    onTap: () {
                      if (!canVerifyUser) {
                        CustomSnackbar.showError(
                          "Incomplete Details",
                          "Phone number and address required to verify user.",
                        );
                        return;
                      }
                      controller.sendOtp();
                    },
                    child: _actionButton(
                      context,
                      Icons.security,
                      canVerifyUser
                          ? "Verify User"
                          : "Waiting for customer details...",
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // Close Order Button — distinct style (warning/orange)
  // ============================================================

  Widget _closeOrderButton(BuildContext context) {
    return CustomContainer(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: rs(context, 14)),
      backgroundColor: AppColors.warning.withOpacity(0.9),
      borderRadius: AppRadii.button(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.white),
          SizedBox(width: rs(context, 8)),
          Text(
            "Close Order",
            style: AppTextStyles.buttonMedium(context).copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 5-Image Capture Bottom Sheet
  // ============================================================

  void _showImageCaptureBottomSheet(
      BuildContext context,
      OrderDetailsController controller,
      ) {
    if (Get.isBottomSheetOpen == true) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: rs(context, 0.68),
          minChildSize: rs(context, 0.5),
          maxChildSize: rs(context, 0.92),
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(rs(context, 28)),
                  topRight: Radius.circular(rs(context, 28)),
                ),
              ),
              child: Column(
                children: [
                  // ── Handle ────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(top: rs(context, 12)),
                    child: CustomContainer(
                      width: rs(context, 40),
                      height: rs(context, 4),
                      backgroundColor:
                      AppColors.textSecondary.withOpacity(0.3),
                      borderRadius:
                      BorderRadius.circular(rs(context, 10)),
                    ),
                  ),

                  // ── Header ────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      rs(context, 20),
                      rs(context, 14),
                      rs(context, 20),
                      rs(context, 4),
                    ),
                    child: Row(
                      children: [
                        CustomContainer(
                          padding: EdgeInsets.all(rs(context, 10)),
                          backgroundColor:
                          AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                          child: Icon(
                            Icons.photo_camera_rounded,
                            color: AppColors.primary,
                            size: rs(context, 22),
                          ),
                        ),
                        SizedBox(width: rs(context, 10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order Completion Photos",
                                style: AppTextStyles.heading4(context)
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Obx(() {
                                final c = controller.capturedImages
                                    .where((f) => f != null)
                                    .length;
                                return Text(
                                  "$c of 5 photos captured",
                                  style: AppTextStyles.bodySmall(context)
                                      .copyWith(
                                      color: AppColors.textSecondary),
                                );
                              }),
                            ],
                          ),
                        ),
                        Obx(() {
                          final count = controller.capturedImages
                              .where((f) => f != null)
                              .length;
                          return _progressBadge(context, count);
                        }),
                      ],
                    ),
                  ),

                  // ── Progress Bar ───────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: rs(context, 20),
                      vertical: rs(context, 10),
                    ),
                    child: Obx(() {
                      final count = controller.capturedImages
                          .where((f) => f != null)
                          .length;
                      return _linearProgressBar(context, count);
                    }),
                  ),

                  // ── Image Grid ────────────────────────────────────
                  Flexible(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(
                        rs(context, 16),
                        rs(context, 4),
                        rs(context, 16),
                        rs(context, 16),
                      ),
                      child: _buildImageGrid(
                          context, controller, sheetContext),
                    ),
                  ),

                  // ── Bottom Bar ────────────────────────────────────
                  _buildSheetBottomBar(context, controller, sheetContext),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _progressBadge(BuildContext context, int count) {
    final isDone = count == 5;
    return CustomContainer(
      padding: EdgeInsets.symmetric(
        horizontal: rs(context, 12),
        vertical: rs(context, 6),
      ),
      backgroundColor: isDone
          ? AppColors.success.withOpacity(0.12)
          : AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(rs(context, 20)),
      child: Text(
        "$count/5",
        style: AppTextStyles.bodySmall(context).copyWith(
          color: isDone ? AppColors.success : AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _linearProgressBar(BuildContext context, int count) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(rs(context, 8)),
      child: LinearProgressIndicator(
        value: count / 5,
        minHeight: rs(context, 6),
        backgroundColor: AppColors.textSecondary.withOpacity(0.12),
        valueColor: AlwaysStoppedAnimation<Color>(
          count == 5 ? AppColors.success : AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildImageGrid(
      BuildContext context,
      OrderDetailsController controller,
      BuildContext sheetContext,
      ) {
    return Column(
      children: [
        // Top row: slots 0, 1 (2 large tiles)
        Row(
          children: [
            Expanded(
                child: _imageSlot(context, controller, 0, isLarge: true)),
            SizedBox(width: rs(context, 10)),
            Expanded(
                child: _imageSlot(context, controller, 1, isLarge: true)),
          ],
        ),

        SizedBox(height: rs(context, 10)),

        // Bottom row: slots 2, 3, 4 (3 smaller tiles)
        Row(
          children: [
            Expanded(child: _imageSlot(context, controller, 2)),
            SizedBox(width: rs(context, 8)),
            Expanded(child: _imageSlot(context, controller, 3)),
            SizedBox(width: rs(context, 8)),
            Expanded(child: _imageSlot(context, controller, 4)),
          ],
        ),

        SizedBox(height: rs(context, 8)),

        // Hint
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: rs(context, 13),
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
            SizedBox(width: rs(context, 4)),
            Text(
              "Tap a slot to capture · Tap filled slot to retake",
              style: AppTextStyles.bodySmall(context).copyWith(
                color: AppColors.textSecondary.withOpacity(0.6),
                fontSize: rs(context, 11),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _imageSlot(
      BuildContext context,
      OrderDetailsController controller,
      int index, {
        bool isLarge = false,
      }) {
    final double height = isLarge ? rs(context, 165) : rs(context, 110);

    return Obx(() {
      final file = controller.capturedImages[index];
      final isFilled = file != null;

      return GestureDetector(
        onTap: () => controller.captureImageAtSlot(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: height,
          decoration: BoxDecoration(
            color: isFilled
                ? Colors.transparent
                : AppColors.textSecondary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(rs(context, 16)),
            border: Border.all(
              color: isFilled
                  ? AppColors.success.withOpacity(0.5)
                  : AppColors.textSecondary.withOpacity(0.2),
              width: isFilled ? 2 : 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(rs(context, 15)),
            child: isFilled
                ? Stack(
              fit: StackFit.expand,
              children: [
                Image.file(file, fit: BoxFit.cover),

                // Dark gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: rs(context, 44),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),

                // Success tick (top-left)
                Positioned(
                  top: rs(context, 7),
                  left: rs(context, 7),
                  child: Container(
                    padding: EdgeInsets.all(rs(context, 3)),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: rs(context, 12),
                    ),
                  ),
                ),

                // Delete icon (top-right)
                Positioned(
                  top: rs(context, 7),
                  right: rs(context, 7),
                  child: GestureDetector(
                    onTap: () =>
                        controller.deleteImageAtSlot(index),
                    child: Container(
                      padding: EdgeInsets.all(rs(context, 5)),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: rs(context, 13),
                      ),
                    ),
                  ),
                ),

                // Photo label (bottom-left)
                Positioned(
                  bottom: rs(context, 6),
                  left: rs(context, 8),
                  child: Text(
                    "Photo ${index + 1}",
                    style:
                    AppTextStyles.bodySmall(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: rs(context, 11),
                    ),
                  ),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(rs(context, 10)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_a_photo_rounded,
                    color: AppColors.primary.withOpacity(0.6),
                    size: rs(context, isLarge ? 26 : 22),
                  ),
                ),
                SizedBox(height: rs(context, 6)),
                Text(
                  "Photo ${index + 1}",
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: rs(context, 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSheetBottomBar(
      BuildContext context,
      OrderDetailsController controller,
      BuildContext sheetContext,
      ) {
    return Obx(() {
      final count = controller.capturedCount;
      final allDone = controller.allImagesCaptured;

      return Container(
        padding: EdgeInsets.fromLTRB(
          rs(context, 16),
          rs(context, 12),
          rs(context, 16),
          rs(context, 24),
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            // Retake All button
            if (count > 0)
              Padding(
                padding: EdgeInsets.only(right: rs(context, 10)),
                child: GestureDetector(
                  onTap: () => controller.clearAllImages(),
                  child: CustomContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: rs(context, 14),
                      vertical: rs(context, 14),
                    ),
                    backgroundColor: AppColors.error.withOpacity(0.07),
                    borderRadius:
                    BorderRadius.circular(rs(context, 14)),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.25),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: AppColors.error,
                      size: rs(context, 22),
                    ),
                  ),
                ),
              ),

            // Main CTA
            Expanded(
              child: GestureDetector(
                onTap: (allDone ||
                    count >= OrderDetailsController.minImageCount)
                    ? () async {
                  Navigator.of(sheetContext).pop();
                  await controller.completeOrder();
                }
                    : count < OrderDetailsController.maxImageCount
                    ? () => controller.captureNextImage()
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding:
                  EdgeInsets.symmetric(vertical: rs(context, 15)),
                  decoration: BoxDecoration(
                    color: allDone
                        ? AppColors.success.withOpacity(0.9)
                        : AppColors.secondary.withOpacity(0.85),
                    borderRadius:
                    BorderRadius.circular(rs(context, 16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        allDone
                            ? Icons.check_circle_outline_rounded
                            : Icons.add_a_photo_rounded,
                        color: Colors.white,
                        size: rs(context, 20),
                      ),
                      SizedBox(width: rs(context, 8)),
                      Text(
                        allDone ||
                            count >=
                                OrderDetailsController.minImageCount
                            ? "Complete Order"
                            : "Capture Photo ${count + 1}",
                        style:
                        AppTextStyles.buttonMedium(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ============================================================
  // OTP Bottom Sheet
  // ============================================================

  void _showOtpBottomSheet(
      BuildContext context,
      OrderDetailsController controller,
      ) {
    print("OTP BOTTOM SHEET SHOW");
    if (Get.isBottomSheetOpen == true) return;

    final RxList<String> digits = <String>[].obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (BuildContext sheetContext) {
        return WillPopScope(
          onWillPop: () async {
            if (controller.remainingSeconds.value <= 0 ||
                controller.isOtpVerified.value ||
                digits.isEmpty) {
              return true;
            }
            return false;
          },
          child: Obx(() {
            final sec = controller.remainingSeconds.value;
            final min = (sec ~/ 60).toString().padLeft(2, '0');
            final s = (sec % 60).toString().padLeft(2, '0');

            if (controller.isOtpVerified.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(sheetContext).pop();
              });
              return const SizedBox.shrink();
            }

            if (sec == 0) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(sheetContext).pop();
              });
            }

            return CustomContainer(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                rs(context, 20),
                rs(context, 18),
                rs(context, 20),
                rs(context, 24),
              ),
              backgroundColor: AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(rs(context, 28)),
                topRight: Radius.circular(rs(context, 28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomContainer(
                    width: rs(context, 40),
                    height: rs(context, 4),
                    backgroundColor:
                    AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(rs(context, 10)),
                  ),
                  SizedBox(height: rs(context, 16)),
                  Row(
                    children: [
                      CustomContainer(
                        padding: EdgeInsets.all(rs(context, 10)),
                        backgroundColor:
                        AppColors.primary.withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(rs(context, 100)),
                        child: Icon(
                          Icons.security,
                          color: AppColors.primary,
                          size: rs(context, 22),
                        ),
                      ),
                      SizedBox(width: rs(context, 10)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Verify User",
                              style: AppTextStyles.heading4(context)
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Enter 6-digit OTP sent to customer",
                              style: AppTextStyles.bodySmall(context)
                                  .copyWith(
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      CustomContainer(
                        padding: EdgeInsets.symmetric(
                          horizontal: rs(context, 10),
                          vertical: rs(context, 6),
                        ),
                        backgroundColor:
                        AppColors.warning.withOpacity(0.12),
                        borderRadius:
                        BorderRadius.circular(rs(context, 20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: AppColors.warning,
                              size: rs(context, 14),
                            ),
                            SizedBox(width: rs(context, 4)),
                            Text(
                              "$min:$s",
                              style: AppTextStyles.bodySmall(context)
                                  .copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: rs(context, 22)),
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (i) {
                        final filled = i < digits.length;
                        final isActive = i == digits.length;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: rs(context, 46),
                          height: rs(context, 54),
                          decoration: BoxDecoration(
                            color: filled
                                ? AppColors.primary.withOpacity(0.08)
                                : isActive
                                ? AppColors.primary.withOpacity(0.04)
                                : AppColors.white,
                            borderRadius:
                            BorderRadius.circular(rs(context, 10)),
                            border: Border.all(
                              color: filled
                                  ? AppColors.primary
                                  : isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary
                                  .withOpacity(0.25),
                              width: filled || isActive ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: filled
                                ? Text(
                              digits[i],
                              style: AppTextStyles.heading4(context).copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                                : isActive
                                ? CustomContainer(
                              width: rs(context, 2),
                              height: rs(context, 22),
                              backgroundColor: AppColors.primary,
                              borderRadius: BorderRadius.zero,
                            )
                                : const SizedBox.shrink(),
                          ),
                        );
                      }),
                    );
                  }),
                  SizedBox(height: rs(context, 20)),
                  _buildNumberPad(
                      context, digits, controller, sheetContext),
                ],
              ),
            );
          }),
        );
      },
    ).then((_) {
      digits.clear();
      controller.otpController.clear();
    });
  }

  Widget _buildNumberPad(
      BuildContext context,
      RxList<String> digits,
      OrderDetailsController controller,
      BuildContext sheetContext,
      ) {
    final List<List<String>> rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['cancel', '0', 'del'],
    ];

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: EdgeInsets.only(bottom: rs(context, 8)),
          child: Row(
            children: row.map((key) {
              final bool isDel = key == 'del';
              final bool isCancel = key == 'cancel';
              final bool isAction = isDel || isCancel;

              return Expanded(
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: rs(context, 5)),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius:
                    BorderRadius.circular(rs(context, 14)),
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(rs(context, 14)),
                      onTap: () async {
                        if (controller.isOtpVerified.value) {
                          Navigator.of(sheetContext).pop();
                          return;
                        }
                        if (isDel) {
                          if (digits.isNotEmpty) {
                            digits.removeLast();
                            controller.otpController.text =
                                digits.join();
                          }
                        } else if (isCancel) {
                          Navigator.of(sheetContext).pop();
                        } else {
                          if (digits.length < 6) {
                            digits.add(key);
                            controller.otpController.text =
                                digits.join();
                            if (digits.length == 6) {
                              await Future.delayed(
                                  const Duration(milliseconds: 250));
                              await controller.confirmOtp();
                            }
                          }
                        }
                      },
                      child: CustomContainer(
                        height: rs(context, 58),
                        backgroundColor: isCancel
                            ? AppColors.error.withOpacity(0.07)
                            : isDel
                            ? AppColors.textSecondary
                            .withOpacity(0.07)
                            : AppColors.white,
                        borderRadius:
                        BorderRadius.circular(rs(context, 14)),
                        border: Border.all(
                          color: isAction
                              ? Colors.transparent
                              : AppColors.textSecondary
                              .withOpacity(0.12),
                        ),
                        boxShadow: isAction
                            ? null
                            : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        child: Center(
                          child: isDel
                              ? Icon(
                            Icons.backspace_outlined,
                            color: AppColors.textSecondary,
                            size: rs(context, 22),
                          )
                              : isCancel
                              ? Text(
                            "Cancel",
                            style: AppTextStyles.bodySmall(
                                context)
                                .copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                              : Text(
                            key,
                            style: AppTextStyles.heading4(
                                context)
                                .copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // Common Widgets
  // ============================================================

  Widget _infoCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    return CustomContainer(
      padding: EdgeInsets.all(rs(context, 12)),
      backgroundColor: AppColors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(rs(context, 14)),
      border: Border.all(color: AppColors.white.withOpacity(0.3)),
      child: Column(
        children: [
          Icon(icon, color: AppColors.white),
          SizedBox(height: rs(context, 6)),
          Text(
            label,
            style: AppTextStyles.bodySmall(context)
                .copyWith(color: AppColors.white.withOpacity(0.9)),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(BuildContext context, order) {
    final isPaid = order.isPaid;
    final color = isPaid ? AppColors.success : AppColors.warning;
    return CustomContainer(
      padding: EdgeInsets.all(rs(context, 12)),
      backgroundColor: AppColors.error.withOpacity(0.12),
      borderRadius: AppRadii.card(context),
      border: Border.all(color: AppColors.error.withOpacity(0.3)),
      child: Row(
        children: [
          _iconChip(
            context,
            icon: isPaid ? Icons.check_circle : Icons.payments,
            color: AppColors.error,
          ),
          SizedBox(width: rs(context, 12)),
          Text(
            isPaid ? "Paid" : "Unpaid",
            style: AppTextStyles.bodyMedium(context)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            "₹${order.totalAmount}",
            style:
            AppTextStyles.heading4(context).copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(
      BuildContext context,
      String phoneText,
      String cleanPhone,
      bool canCall,
      ) {
    return CustomContainer(
      backgroundColor: AppColors.white,
      borderRadius: AppRadii.card(context),
      border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(rs(context, 14)),
            child: Row(
              children: [
                _iconChip(context, icon: Icons.phone_rounded),
                SizedBox(width: rs(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Phone Number",
                        style: AppTextStyles.bodySmall(context)
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      SizedBox(height: rs(context, 4)),
                      Text(
                        phoneText,
                        style:
                        AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: canCall
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(rs(context, 14)),
            child: InkWell(
              onTap: canCall
                  ? () async {
                final uri = Uri.parse("tel:$cleanPhone");
                if (!await launchUrl(uri,
                    mode: LaunchMode.externalApplication)) {
                  CustomSnackbar.showError(
                      "Error", "Could not open dialer");
                }
              }
                  : null,
              borderRadius: AppRadii.button(context),
              child: Opacity(
                opacity: canCall ? 1 : 0.5,
                child: _actionButton(
                  context,
                  Icons.call_rounded,
                  canCall ? "Call Customer" : "Phone available later",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _locationCard(
  //     BuildContext context,
  //     String addressText,
  //     bool canNavigate,
  //     address,
  //     ) {
  //   return CustomContainer(
  //     backgroundColor: AppColors.white,
  //     borderRadius: AppRadii.card(context),
  //     border: Border.all(color: AppColors.primary.withOpacity(0.08)),
  //     child: Column(
  //       children: [
  //         Padding(
  //           padding: EdgeInsets.all(rs(context, 14)),
  //           child: Row(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               _iconChip(context, icon: Icons.location_on_rounded),
  //               SizedBox(width: rs(context, 12)),
  //               Expanded(
  //                 child: Text(
  //                   addressText,
  //                   style: AppTextStyles.bodyMedium(context).copyWith(
  //                     fontWeight: FontWeight.w600,
  //                     color: canNavigate
  //                         ? AppColors.textPrimary
  //                         : AppColors.textSecondary,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const Divider(height: 1),
  //         Padding(
  //           padding: EdgeInsets.all(rs(context, 14)),
  //           child: InkWell(
  //             onTap: canNavigate
  //                 ? () async {
  //               final uri = Uri.parse(
  //                 "https://www.google.com/maps/dir/?api=1"
  //                     "&origin=Current+Location"
  //                     "&destination=${address.latitude},${address.longitude}"
  //                     "&travelmode=driving",
  //               );
  //               if (!await launchUrl(uri,
  //                   mode: LaunchMode.externalApplication)) {
  //                 CustomSnackbar.showError(
  //                     "Error", "Could not open Google Maps");
  //               }
  //             }
  //                 : null,
  //             borderRadius: AppRadii.button(context),
  //             child: Opacity(
  //               opacity: canNavigate ? 1 : 0.5,
  //               child: _actionButton(
  //                 context,
  //                 Icons.navigation,
  //                 canNavigate
  //                     ? "Start Navigation"
  //                     : "Address available later",
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _locationCard(
      BuildContext context,
      String addressText,
      bool canNavigate,
      address,
      ) {
    return CustomContainer(
      backgroundColor: AppColors.white,
      borderRadius: AppRadii.card(context),
      border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(rs(context, 14)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconChip(context, icon: Icons.location_on_rounded),
                SizedBox(width: rs(context, 12)),
                Expanded(
                  child: Text(
                    addressText,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: canNavigate
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(rs(context, 14)),
            child: InkWell(
              onTap: canNavigate
                  ? () {
                // ✅ In-app navigation — no Google Maps app needed
                Get.to(
                      () => NavigationPage(
                    destinationLat: address.latitude!,
                    destinationLng: address.longitude!,
                    destinationName:
                    address.formattedAddress ?? "Customer Location",
                  ),
                  transition: Transition.downToUp,
                  duration: const Duration(milliseconds: 400),
                );
              }
                  : null,
              borderRadius: AppRadii.button(context),
              child: Opacity(
                opacity: canNavigate ? 1 : 0.5,
                child: _actionButton(
                  context,
                  Icons.navigation,
                  canNavigate
                      ? "Start Navigation"
                      : "Address available later",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String text) {
    return CustomContainer(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: rs(context, 14)),
      backgroundColor: AppColors.secondary.withOpacity(0.8),
      borderRadius: AppRadii.button(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.white),
          SizedBox(width: rs(context, 8)),
          Text(
            text,
            style: AppTextStyles.buttonMedium(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconChip(BuildContext context,
      {required IconData icon, Color? color}) {
    return CustomContainer(
      padding: EdgeInsets.all(rs(context, 10)),
      backgroundColor: (color ?? AppColors.secondary).withOpacity(0.12),
      borderRadius: BorderRadius.circular(rs(context, 12)),
      child: Icon(
        icon,
        color: color ?? AppColors.secondary,
        size: rs(context, 22),
      ),
    );
  }

  Widget _section(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Widget child,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _iconChip(context, icon: icon, color: AppColors.primary),
            SizedBox(width: rs(context, 8)),
            Text(
              title,
              style: AppTextStyles.bodyLarge(context)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: rs(context, 10)),
        child,
      ],
    );
  }
}