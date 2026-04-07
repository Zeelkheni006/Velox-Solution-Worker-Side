import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/api/Api_Service/Addon_Item/addon_item_model.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../../../../core/utils/custome_snakbar.dart';
import '../../../../core/utils/map_navigation_page.dart';
import '../../../../core/utils/reschedule_bottom_sheet.dart';
import '../controllers/order_details_controller.dart';

class OrderDetailsPage extends StatelessWidget {
  final int orderId;
  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return GetX<OrderDetailsController>(
      init: OrderDetailsController(orderId),
      builder: (controller) {
        // ── Shimmer Loading State ──────────────────────────────────────────
        if (controller.isLoading.value) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.appbar,
              elevation: 0,
              centerTitle: true,
              leading: Padding(
                padding: EdgeInsets.all(rs(context, 8)),
                child: CircleAvatar(
                  radius: rs(context, 20),
                  backgroundColor: AppColors.black.withOpacity(0.15),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: AppColors.black,
                      size: rs(context, 18),
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
              ),
              title: Text("Order Details",
                  style: AppTextStyles.heading3(context)),
            ),
            body: _ShimmerOrderDetails(context: context),
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
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.appbar,
            elevation: 0,
            centerTitle: true,
            leading: Padding(
              padding: EdgeInsets.all(rs(context, 8)),
              child: CircleAvatar(
                radius: rs(context, 20),
                backgroundColor: AppColors.black.withOpacity(0.15),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: AppColors.black,
                    size: rs(context, 18),
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
            title: Text("Order Details",
                style: AppTextStyles.heading3(context)),
          ),
          body: Stack(
            children: [
              // ── Pull-to-Refresh Wrapper ───────────────────────────────
              RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                displacement: rs(context, 40),
                strokeWidth: 2.5,
                onRefresh: () => controller.refreshOrder(),
                child: SingleChildScrollView(
                  // physics must be AlwaysScrollable for pull-to-refresh
                  // to trigger even when content is shorter than screen
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: rs(context, 110)),
                    child: Column(
                      children: [
                        // ── Hero Header ──────────────────────────────────
                        CustomContainer(
                          width: double.infinity,
                          padding: EdgeInsets.all(rs(context, 16)),
                          backgroundColor: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft:
                            Radius.circular(rs(context, 24)),
                            bottomRight:
                            Radius.circular(rs(context, 24)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _infoCard(
                                  context,
                                  icon: Icons.schedule_rounded,
                                  label: "Time Slot",
                                  value: order.slotTime
                                      .split(' - ')
                                      .first
                                      .trim(),
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
                                child: _contactCard(context, phoneText,
                                    cleanPhone, canCall),
                              ),
                              SizedBox(height: rs(context, 20)),
                              _section(
                                context,
                                title: "Service Location",
                                icon: Icons.location_on_rounded,
                                child: _locationCard(context, addressText,
                                    canNavigate, address),
                              ),

                              // ── Addon Module ─────────────────────────
                              Obx(() {
                                if (!controller.isOtpVerified.value) {
                                  return const SizedBox.shrink();
                                }
                                if (controller.orderIsFinal.value) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  children: [
                                    SizedBox(height: rs(context, 20)),
                                    _addonSection(context, controller),
                                  ],
                                );
                              }),

                              SizedBox(height: rs(context, 300)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Floating Bottom Bar ──────────────────────────────────
              Obx(() {
                if (controller.orderIsFinal.value) {
                  final isCancelled =
                      controller.finalOrderStatus == 'cancelled';
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
                        padding: EdgeInsets.symmetric(
                            vertical: rs(context, 14)),
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
                              color: isCancelled
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                            SizedBox(width: rs(context, 8)),
                            Text(
                              isCancelled
                                  ? "Order Cancelled"
                                  : "Order Closed",
                              style: AppTextStyles.buttonMedium(context)
                                  .copyWith(
                                fontWeight: FontWeight.w700,
                                color: isCancelled
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (controller.orderServiceCompleted.value &&
                    controller.isPaymentUnpaid) {
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
                      padding: EdgeInsets.fromLTRB(
                        rs(context, 16),
                        rs(context, 12),
                        rs(context, 16),
                        rs(context, 24),
                      ),
                      backgroundColor: AppColors.surface,
                      borderRadius: AppRadii.button(context),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _showImageCaptureBottomSheet(
                                context, controller),
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
                          SizedBox(height: rs(context, 10)),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      RescheduleBottomSheet.show(context,
                                          controller: controller),
                                  child: CustomContainer(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        vertical: rs(context, 13)),
                                    backgroundColor: Colors.transparent,
                                    borderRadius:
                                    AppRadii.button(context),
                                    border: Border.all(
                                      color: AppColors.warning
                                          .withOpacity(0.55),
                                      width: 1.5,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.event_repeat_rounded,
                                          color: AppColors.warning,
                                          size: rs(context, 18),
                                        ),
                                        SizedBox(width: rs(context, 6)),
                                        Text(
                                          "Reschedule",
                                          style: AppTextStyles
                                              .buttonMedium(context)
                                              .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: rs(context, 10)),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _showCancelOrderBottomSheet(
                                          context, controller),
                                  child: CustomContainer(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        vertical: rs(context, 13)),
                                    backgroundColor: Colors.transparent,
                                    borderRadius:
                                    AppRadii.button(context),
                                    border: Border.all(
                                      color: AppColors.error
                                          .withOpacity(0.55),
                                      width: 1.5,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cancel_outlined,
                                          color: AppColors.error,
                                          size: rs(context, 18),
                                        ),
                                        SizedBox(width: rs(context, 6)),
                                        Text(
                                          "Cancel",
                                          style: AppTextStyles
                                              .buttonMedium(context)
                                              .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.showOtpField.value) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!(Get.isBottomSheetOpen == true) &&
                        !controller.isOtpVerified.value) {
                      _showOtpBottomSheet(context, controller);
                    }
                  });
                  return const SizedBox.shrink();
                }

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

  // ══════════════════════════════════════════════════════════════════════════
  // SHIMMER SKELETON WIDGET
  // ══════════════════════════════════════════════════════════════════════════

  Widget _ShimmerOrderDetails({required BuildContext context}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1200),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // Hero Header Shimmer
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(rs(context, 16)),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(rs(context, 24)),
                  bottomRight: Radius.circular(rs(context, 24)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: _shimmerInfoCard(context)),
                  SizedBox(width: rs(context, 10)),
                  Expanded(child: _shimmerInfoCard(context)),
                ],
              ),
            ),

            SizedBox(height: rs(context, 20)),

            Padding(
              padding:
              EdgeInsets.symmetric(horizontal: rs(context, 16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment shimmer
                  _shimmerSectionTitle(context),
                  SizedBox(height: rs(context, 10)),
                  _shimmerCard(context, height: rs(context, 68)),

                  SizedBox(height: rs(context, 24)),

                  // Contact shimmer
                  _shimmerSectionTitle(context),
                  SizedBox(height: rs(context, 10)),
                  _shimmerCard(context, height: rs(context, 120)),

                  SizedBox(height: rs(context, 24)),

                  // Location shimmer
                  _shimmerSectionTitle(context),
                  SizedBox(height: rs(context, 10)),
                  _shimmerCard(context, height: rs(context, 130)),

                  SizedBox(height: rs(context, 24)),

                  // Addon shimmer block
                  _shimmerCard(context, height: rs(context, 56)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(rs(context, 14)),
      ),
      child: Column(
        children: [
          Container(
            width: rs(context, 24),
            height: rs(context, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: rs(context, 6)),
          Container(
            width: rs(context, 60),
            height: rs(context, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(rs(context, 4)),
            ),
          ),
          SizedBox(height: rs(context, 4)),
          Container(
            width: rs(context, 80),
            height: rs(context, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(rs(context, 4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerSectionTitle(BuildContext context) {
    return Row(
      children: [
        Container(
          width: rs(context, 42),
          height: rs(context, 42),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(rs(context, 12)),
          ),
        ),
        SizedBox(width: rs(context, 8)),
        Container(
          width: rs(context, 120),
          height: rs(context, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(rs(context, 6)),
          ),
        ),
      ],
    );
  }

  Widget _shimmerCard(BuildContext context, {required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 14)),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Cancel Order Bottom Sheet
  // ══════════════════════════════════════════════════════════════════════════

  void _showCancelOrderBottomSheet(
      BuildContext context, OrderDetailsController controller) {
    if (Get.isBottomSheetOpen == true) return;

    final noteCtrl = controller.cancelNoteController;
    final RxDouble visitingFee = 0.0.obs;
    final RxBool isNoteValid = false.obs;
    final RxString feeError = ''.obs;

    const List<double> quickFees = [0, 100, 150, 200, 250, 300];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.74,
            minChildSize: 0.5,
            maxChildSize: 0.92,
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        rs(context, 20),
                        rs(context, 16),
                        rs(context, 20),
                        rs(context, 4),
                      ),
                      child: Row(
                        children: [
                          CustomContainer(
                            padding: EdgeInsets.all(rs(context, 10)),
                            backgroundColor:
                            AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                            child: Icon(
                              Icons.cancel_outlined,
                              color: AppColors.error,
                              size: rs(context, 22),
                            ),
                          ),
                          SizedBox(width: rs(context, 12)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cancel Order",
                                  style: AppTextStyles.heading4(context)
                                      .copyWith(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Provide reason & visiting fee",
                                  style: AppTextStyles.bodySmall(context)
                                      .copyWith(
                                      color:
                                      AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: rs(context, 20),
                      color: AppColors.textSecondary.withOpacity(0.1),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          rs(context, 16),
                          rs(context, 4),
                          rs(context, 16),
                          rs(context, 16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cancellation Reason *",
                              style: AppTextStyles.bodyMedium(context)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: rs(context, 8)),
                            CustomContainer(
                              backgroundColor: AppColors.white,
                              borderRadius: AppRadii.card(context),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.2),
                                width: 1.5,
                              ),
                              child: TextField(
                                controller: noteCtrl,
                                maxLines: 4,
                                maxLength: 300,
                                onChanged: (v) {
                                  isNoteValid.value =
                                      v.trim().length >= 10;
                                },
                                style: AppTextStyles.bodyMedium(context)
                                    .copyWith(
                                    color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText:
                                  "Explain why you are cancelling (min 10 characters)...",
                                  hintStyle:
                                  AppTextStyles.bodySmall(context)
                                      .copyWith(
                                    color: AppColors.textSecondary
                                        .withOpacity(0.6),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                  EdgeInsets.all(rs(context, 14)),
                                  counterStyle: AppTextStyles.bodySmall(
                                      context)
                                      .copyWith(
                                    color: AppColors.textSecondary
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: rs(context, 10)),
                            Text(
                              "Visiting Fee (₹)",
                              style: AppTextStyles.bodyMedium(context)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: rs(context, 4)),
                            Text(
                              "Amount to collect from customer for the visit",
                              style: AppTextStyles.bodySmall(context)
                                  .copyWith(
                                  color: AppColors.textSecondary),
                            ),
                            SizedBox(height: rs(context, 10)),
                            Obx(() => Wrap(
                              spacing: rs(context, 8),
                              runSpacing: rs(context, 8),
                              children: quickFees.map((fee) {
                                final isSelected =
                                    visitingFee.value == fee;
                                return GestureDetector(
                                  onTap: () =>
                                  visitingFee.value = fee,
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 180),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: rs(context, 16),
                                      vertical: rs(context, 9),
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.error
                                          : AppColors.white,
                                      borderRadius:
                                      BorderRadius.circular(
                                          rs(context, 10)),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.error
                                            : AppColors.textSecondary
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: Text(
                                      fee == 0
                                          ? "₹0 (Free)"
                                          : "₹${fee.toInt()}",
                                      style: AppTextStyles.bodySmall(
                                          context)
                                          .copyWith(
                                        color: isSelected
                                            ? AppColors.white
                                            : AppColors.textPrimary,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            )),
                            SizedBox(height: rs(context, 12)),
                            CustomContainer(
                              backgroundColor: AppColors.white,
                              borderRadius: AppRadii.card(context),
                              border: Border.all(
                                color: AppColors.textSecondary
                                    .withOpacity(0.2),
                                width: 1.5,
                              ),
                              child: TextField(
                                keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                                onChanged: (v) {
                                  if (v.isEmpty) {
                                    feeError.value = '';
                                    return;
                                  }
                                  final parsed = double.tryParse(v);
                                  if (parsed != null && parsed >= 0) {
                                    visitingFee.value = parsed;
                                    feeError.value = '';
                                  } else {
                                    feeError.value =
                                    'Enter a valid amount';
                                  }
                                },
                                style: AppTextStyles.bodyMedium(context)
                                    .copyWith(
                                    color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: "Or type a custom amount...",
                                  hintStyle:
                                  AppTextStyles.bodySmall(context)
                                      .copyWith(
                                    color: AppColors.textSecondary
                                        .withOpacity(0.6),
                                  ),
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(
                                        left: rs(context, 14),
                                        right: rs(context, 8),
                                        top: rs(context, 13),
                                        bottom: rs(context, 13)),
                                    child: Text(
                                      "₹",
                                      style:
                                      AppTextStyles.bodyLarge(context)
                                          .copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  prefixIconConstraints:
                                  const BoxConstraints(minWidth: 0),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: rs(context, 14),
                                    vertical: rs(context, 13),
                                  ),
                                ),
                              ),
                            ),
                            Obx(() => feeError.value.isNotEmpty
                                ? Padding(
                              padding: EdgeInsets.only(
                                  top: rs(context, 6),
                                  left: rs(context, 4)),
                              child: Text(
                                feeError.value,
                                style: AppTextStyles.bodySmall(
                                    context)
                                    .copyWith(
                                    color: AppColors.error),
                              ),
                            )
                                : const SizedBox.shrink()),
                            SizedBox(height: rs(context, 24)),
                          ],
                        ),
                      ),
                    ),
                    Container(
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
                            color:
                            AppColors.textSecondary.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(() {
                              final canSubmit = isNoteValid.value &&
                                  feeError.value.isEmpty;
                              return GestureDetector(
                                onTap: canSubmit
                                    ? () async {
                                  if (Get.isBottomSheetOpen ==
                                      true) {
                                    Get.back();
                                  }
                                  await Future.delayed(const Duration(
                                      milliseconds: 300));
                                  await controller.cancelOrder(
                                    note: controller
                                        .cancelNoteController.text
                                        .trim(),
                                    visitingFee: visitingFee.value,
                                  );
                                }
                                    : null,
                                child: AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 220),
                                  padding: EdgeInsets.symmetric(
                                      vertical: rs(context, 15)),
                                  decoration: BoxDecoration(
                                    color: canSubmit
                                        ? AppColors.error
                                        : AppColors.error
                                        .withOpacity(0.35),
                                    borderRadius:
                                    AppRadii.button(context),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.white,
                                        size: rs(context, 18),
                                      ),
                                      SizedBox(width: rs(context, 8)),
                                      Text(
                                        "Confirm Cancel",
                                        style: AppTextStyles.buttonMedium(
                                            context)
                                            .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADDON SECTION
  // ══════════════════════════════════════════════════════════════════════════

  Widget _addonSection(
      BuildContext context, OrderDetailsController orderCtrl) {
    final addonCtrl = Get.put(
      AddonController(orderId),
      tag: 'addon_$orderId',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => addonCtrl.isAddonExpanded.toggle(),
          child: CustomContainer(
            padding: EdgeInsets.symmetric(
              horizontal: rs(context, 14),
              vertical: rs(context, 12),
            ),
            backgroundColor: AppColors.white,
            borderRadius: AppRadii.card(context),
            border:
            Border.all(color: AppColors.primary.withOpacity(0.15)),
            child: Obx(() => Row(
              children: [
                _iconChip(context,
                    icon: Icons.build_circle_rounded,
                    color: AppColors.primary),
                SizedBox(width: rs(context, 10)),
                Text(
                  "Addon Parts",
                  style: AppTextStyles.bodyLarge(context)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (addonCtrl.addonTotal.value > 0) ...[
                  CustomContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: rs(context, 10),
                      vertical: rs(context, 4),
                    ),
                    backgroundColor:
                    AppColors.primary.withOpacity(0.1),
                    borderRadius:
                    BorderRadius.circular(rs(context, 20)),
                    child: Text(
                      "₹${addonCtrl.addonTotal.value.toStringAsFixed(0)}",
                      style:
                      AppTextStyles.bodySmall(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: rs(context, 8)),
                ],
                if (!addonCtrl.isAddonExpanded.value &&
                    addonCtrl.orderAddons.isNotEmpty) ...[
                  CustomContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: rs(context, 8),
                      vertical: rs(context, 4),
                    ),
                    backgroundColor:
                    AppColors.success.withOpacity(0.1),
                    borderRadius:
                    BorderRadius.circular(rs(context, 20)),
                    child: Text(
                      "${addonCtrl.orderAddons.length} added",
                      style:
                      AppTextStyles.bodySmall(context).copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: rs(context, 8)),
                ],
                AnimatedRotation(
                  turns:
                  addonCtrl.isAddonExpanded.value ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                    size: rs(context, 22),
                  ),
                ),
              ],
            )),
          ),
        ),
        Obx(() => AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: addonCtrl.isAddonExpanded.value
              ? Column(
            children: [
              SizedBox(height: rs(context, 10)),
              _addonSearchBar(context, addonCtrl),
              SizedBox(height: rs(context, 10)),
              Obx(() {
                if (addonCtrl.isSearching.value) {
                  return _centeredLoader(context);
                }
                if (addonCtrl.isLoadingAll.value) {
                  return _centeredLoader(context);
                }
                if (addonCtrl.searchResults.isNotEmpty) {
                  return _searchResultsList(
                      context, addonCtrl);
                }
                if (addonCtrl.searchQuery.value.isNotEmpty &&
                    !addonCtrl.isSearching.value &&
                    addonCtrl.searchResults.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: rs(context, 10)),
                    child: Center(
                      child: Text(
                        "No parts found for '${addonCtrl.searchQuery.value}'",
                        style: AppTextStyles.bodySmall(context)
                            .copyWith(
                            color:
                            AppColors.textSecondary),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              SizedBox(height: rs(context, 10)),
              Obx(() {
                if (addonCtrl.isLoadingAddons.value) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: rs(context, 14)),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    ),
                  );
                }
                if (addonCtrl.orderAddons.isEmpty) {
                  return CustomContainer(
                    width: double.infinity,
                    padding:
                    EdgeInsets.all(rs(context, 16)),
                    backgroundColor: AppColors.textSecondary
                        .withOpacity(0.05),
                    borderRadius: AppRadii.card(context),
                    border: Border.all(
                        color: AppColors.textSecondary
                            .withOpacity(0.12)),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.textSecondary
                              .withOpacity(0.4),
                          size: rs(context, 32),
                        ),
                        SizedBox(height: rs(context, 8)),
                        Text(
                          "No addon parts added yet",
                          style: AppTextStyles.bodySmall(
                              context)
                              .copyWith(
                              color: AppColors.textSecondary
                                  .withOpacity(0.6)),
                        ),
                      ],
                    ),
                  );
                }
                return _orderAddonsList(context, addonCtrl);
              }),
            ],
          )
              : const SizedBox(width: double.infinity, height: 0),
        )),
      ],
    );
  }

  Widget _centeredLoader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs(context, 12)),
      child: Center(
        child: SizedBox(
          width: rs(context, 22),
          height: rs(context, 22),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _addonSearchBar(
      BuildContext context, AddonController addonCtrl) {
    return CustomContainer(
      backgroundColor: AppColors.white,
      borderRadius: AppRadii.card(context),
      border: Border.all(
          color: AppColors.primary.withOpacity(0.15), width: 1.5),
      child: TextField(
        onChanged: (v) => addonCtrl.searchParts(v),
        style: AppTextStyles.bodyMedium(context)
            .copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: "Search parts (e.g. nail, bolt...)",
          hintStyle: AppTextStyles.bodySmall(context)
              .copyWith(color: AppColors.textSecondary.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search_rounded,
              color: AppColors.primary, size: rs(context, 20)),
          suffixIcon: Obx(() =>
          addonCtrl.searchQuery.value.isNotEmpty
              ? GestureDetector(
            onTap: () => addonCtrl.clearSearch(),
            child: Icon(Icons.close_rounded,
                color: AppColors.textSecondary,
                size: rs(context, 18)),
          )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: rs(context, 14),
            vertical: rs(context, 13),
          ),
        ),
      ),
    );
  }

  Widget _searchResultsList(
      BuildContext context, AddonController addonCtrl) {
    return Obx(() {
      return SizedBox(
        height: rs(context, 210),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: rs(context, 4)),
          itemCount: addonCtrl.searchResults.length,
          separatorBuilder: (_, __) =>
              SizedBox(width: rs(context, 10)),
          itemBuilder: (context, idx) {
            final part = addonCtrl.searchResults[idx];
            return _searchResultCard(context, addonCtrl, part);
          },
        ),
      );
    });
  }

  Widget _searchResultCard(BuildContext context,
      AddonController addonCtrl, AddonPartModel part) {
    return CustomContainer(
      width: rs(context, 150),
      backgroundColor: AppColors.white,
      borderRadius: AppRadii.card(context),
      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      child: Padding(
        padding: EdgeInsets.all(rs(context, 12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: _partThumbnail(context, part)),
            SizedBox(height: rs(context, 4)),
            Text(
              part.partName,
              style: AppTextStyles.bodyMedium(context)
                  .copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: rs(context, 2)),
            Text(
              "₹${part.amount.toStringAsFixed(0)} per unit",
              style: AppTextStyles.bodySmall(context)
                  .copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            Obx(() {
              final isAdding = addonCtrl.isAdding.value;
              return GestureDetector(
                onTap:
                isAdding ? null : () => addonCtrl.addPart(part),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: double.infinity,
                  padding:
                  EdgeInsets.symmetric(vertical: rs(context, 8)),
                  decoration: BoxDecoration(
                    color: isAdding
                        ? AppColors.primary.withOpacity(0.4)
                        : AppColors.primary,
                    borderRadius:
                    BorderRadius.circular(rs(context, 10)),
                  ),
                  child: isAdding
                      ? Center(
                    child: SizedBox(
                      width: rs(context, 16),
                      height: rs(context, 16),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded,
                          color: Colors.white,
                          size: rs(context, 16)),
                      SizedBox(width: rs(context, 4)),
                      Text(
                        "Add",
                        style: AppTextStyles.bodySmall(context)
                            .copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _partThumbnail(BuildContext context, AddonPartModel part) {
    final url = part.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(rs(context, 10)),
      child: url != null
          ? Image.network(
        url,
        height: rs(context, 85),
        fit: BoxFit.fill,
        errorBuilder: (_, __, ___) => _partIconFallback(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: rs(context, 44),
            height: rs(context, 44),
            child: Center(
              child: SizedBox(
                width: rs(context, 16),
                height: rs(context, 16),
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppColors.primary,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
      )
          : _partIconFallback(context),
    );
  }

  Widget _partIconFallback(BuildContext context) {
    return Image.asset(AppAssets.logo,
        height: rs(context, 180), fit: BoxFit.cover);
  }

  Widget _orderAddonsList(
      BuildContext context, AddonController addonCtrl) {
    return CustomContainer(
      backgroundColor: AppColors.white,
      borderRadius: AppRadii.card(context),
      border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      child: Obx(() {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                rs(context, 14),
                rs(context, 10),
                rs(context, 14),
                rs(context, 6),
              ),
              child: Row(
                children: [
                  Text(
                    "Added Parts",
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${addonCtrl.orderAddons.length} item${addonCtrl.orderAddons.length == 1 ? '' : 's'}",
                    style: AppTextStyles.bodySmall(context)
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                color: AppColors.textSecondary.withOpacity(0.08)),
            ...addonCtrl.orderAddons.asMap().entries.map((entry) {
              final idx = entry.key;
              final addon = entry.value;
              final isLast =
                  idx == addonCtrl.orderAddons.length - 1;
              final isRemoving =
                  addonCtrl.removingId.value == addon.id;

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: rs(context, 14),
                      vertical: rs(context, 12),
                    ),
                    child: Row(
                      children: [
                        CustomContainer(
                          padding: EdgeInsets.all(rs(context, 8)),
                          backgroundColor:
                          AppColors.primary.withOpacity(0.08),
                          borderRadius:
                          BorderRadius.circular(rs(context, 10)),
                          child: Text(
                            "×${addon.quantity}",
                            style: AppTextStyles.bodySmall(context)
                                .copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: rs(context, 10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                addon.partName,
                                style:
                                AppTextStyles.bodyMedium(context)
                                    .copyWith(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "₹${addon.unitPrice.toStringAsFixed(0)} × ${addon.quantity} = ₹${addon.totalPrice.toStringAsFixed(0)}",
                                style:
                                AppTextStyles.bodySmall(context)
                                    .copyWith(
                                    color:
                                    AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: isRemoving
                              ? null
                              : () => addonCtrl.removePart(addon),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.all(rs(context, 8)),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(
                                  rs(context, 10)),
                              border: Border.all(
                                  color:
                                  AppColors.error.withOpacity(0.2)),
                            ),
                            child: isRemoving
                                ? SizedBox(
                              width: rs(context, 16),
                              height: rs(context, 16),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                                : Icon(
                              Icons.remove_rounded,
                              color: AppColors.error,
                              size: rs(context, 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                        height: 1,
                        color:
                        AppColors.textSecondary.withOpacity(0.08)),
                ],
              );
            }),
            Divider(
                height: 1,
                color: AppColors.textSecondary.withOpacity(0.12)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rs(context, 14),
                vertical: rs(context, 12),
              ),
              child: Row(
                children: [
                  Text(
                    "Addon Total",
                    style: AppTextStyles.bodyMedium(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    "₹${addonCtrl.addonTotal.value.toStringAsFixed(0)}",
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Close Order Button
  // ══════════════════════════════════════════════════════════════════════════

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

  // ══════════════════════════════════════════════════════════════════════════
  // 5-Image Capture Bottom Sheet
  // ══════════════════════════════════════════════════════════════════════════

  void _showImageCaptureBottomSheet(
      BuildContext context, OrderDetailsController controller) {
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
          initialChildSize: rs(context, 0.8),
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
                                    .copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                              Obx(() {
                                final c = controller.capturedImages
                                    .where((f) => f != null)
                                    .length;
                                return Text(
                                  "$c of 5 photos captured",
                                  style: AppTextStyles.bodySmall(context)
                                      .copyWith(
                                      color:
                                      AppColors.textSecondary),
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
                  _buildSheetBottomBar(
                      context, controller, sheetContext),
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

  Widget _buildImageGrid(BuildContext context,
      OrderDetailsController controller, BuildContext sheetContext) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child:
                _imageSlot(context, controller, 0, isLarge: true)),
            SizedBox(width: rs(context, 10)),
            Expanded(
                child:
                _imageSlot(context, controller, 1, isLarge: true)),
          ],
        ),
        SizedBox(height: rs(context, 10)),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded,
                size: rs(context, 13),
                color: AppColors.textSecondary.withOpacity(0.6)),
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
      BuildContext context, OrderDetailsController controller, int index,
      {bool isLarge = false}) {
    final double height =
    isLarge ? rs(context, 165) : rs(context, 110);

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
                Positioned(
                  top: rs(context, 7),
                  left: rs(context, 7),
                  child: Container(
                    padding: EdgeInsets.all(rs(context, 3)),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check_rounded,
                        color: Colors.white,
                        size: rs(context, 12)),
                  ),
                ),
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
                      child: Icon(Icons.close_rounded,
                          color: Colors.white,
                          size: rs(context, 13)),
                    ),
                  ),
                ),
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
                  style:
                  AppTextStyles.bodySmall(context).copyWith(
                    color:
                    AppColors.textSecondary.withOpacity(0.7),
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

  Widget _buildSheetBottomBar(BuildContext context,
      OrderDetailsController controller, BuildContext sheetContext) {
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
                  color: AppColors.textSecondary.withOpacity(0.1))),
        ),
        child: Row(
          children: [
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
                        color: AppColors.error.withOpacity(0.25)),
                    child: Icon(Icons.refresh_rounded,
                        color: AppColors.error, size: rs(context, 22)),
                  ),
                ),
              ),
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
                        style: AppTextStyles.buttonMedium(context)
                            .copyWith(
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

  // ══════════════════════════════════════════════════════════════════════════
  // OTP Bottom Sheet
  // ══════════════════════════════════════════════════════════════════════════

  void _showOtpBottomSheet(
      BuildContext context, OrderDetailsController controller) {
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
                    borderRadius:
                    BorderRadius.circular(rs(context, 10)),
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
                        child: Icon(Icons.security,
                            color: AppColors.primary,
                            size: rs(context, 22)),
                      ),
                      SizedBox(width: rs(context, 10)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Verify User",
                                style: AppTextStyles.heading4(context)
                                    .copyWith(
                                    fontWeight: FontWeight.bold)),
                            Text("Enter 6-digit OTP sent to customer",
                                style: AppTextStyles.bodySmall(context)
                                    .copyWith(
                                    color:
                                    AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      CustomContainer(
                        padding: EdgeInsets.symmetric(
                            horizontal: rs(context, 10),
                            vertical: rs(context, 6)),
                        backgroundColor:
                        AppColors.warning.withOpacity(0.12),
                        borderRadius:
                        BorderRadius.circular(rs(context, 20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined,
                                color: AppColors.warning,
                                size: rs(context, 14)),
                            SizedBox(width: rs(context, 4)),
                            Text("$min:$s",
                                style: AppTextStyles.bodySmall(context)
                                    .copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: rs(context, 22)),
                  Obx(() => Row(
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
                              ? AppColors.primary
                              .withOpacity(0.04)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(
                              rs(context, 10)),
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
                              ? Text(digits[i],
                              style:
                              AppTextStyles.heading4(context)
                                  .copyWith(
                                  color: AppColors.primary,
                                  fontWeight:
                                  FontWeight.bold))
                              : isActive
                              ? CustomContainer(
                            width: rs(context, 2),
                            height: rs(context, 22),
                            backgroundColor:
                            AppColors.primary,
                            borderRadius:
                            BorderRadius.zero,
                          )
                              : const SizedBox.shrink(),
                        ),
                      );
                    }),
                  )),
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
      BuildContext sheetContext) {
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
                  padding: EdgeInsets.symmetric(
                      horizontal: rs(context, 5)),
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
                              await Future.delayed(const Duration(
                                  milliseconds: 250));
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
                              : AppColors.textSecondary.withOpacity(0.12),
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
                              ? Icon(Icons.backspace_outlined,
                              color: AppColors.textSecondary,
                              size: rs(context, 22))
                              : isCancel
                              ? Text("Cancel",
                              style:
                              AppTextStyles.bodySmall(context)
                                  .copyWith(
                                  color: AppColors.error,
                                  fontWeight:
                                  FontWeight.w600))
                              : Text(key,
                              style:
                              AppTextStyles.heading4(context)
                                  .copyWith(
                                  fontWeight:
                                  FontWeight.w600,
                                  color: AppColors
                                      .textPrimary)),
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

  // ══════════════════════════════════════════════════════════════════════════
  // Common Widgets
  // ══════════════════════════════════════════════════════════════════════════

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
          Text(label,
              style: AppTextStyles.bodySmall(context)
                  .copyWith(color: AppColors.white.withOpacity(0.9))),
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
    return CustomContainer(
      padding: EdgeInsets.all(rs(context, 12)),
      backgroundColor: AppColors.error.withOpacity(0.12),
      borderRadius: AppRadii.card(context),
      border: Border.all(color: AppColors.error.withOpacity(0.3)),
      child: Row(
        children: [
          _iconChip(context,
              icon: isPaid ? Icons.check_circle : Icons.payments,
              color: AppColors.error),
          SizedBox(width: rs(context, 12)),
          Text(
            isPaid ? "Paid" : "Unpaid",
            style: AppTextStyles.bodyMedium(context)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            "₹${order.totalAmount}",
            style: AppTextStyles.heading4(context)
                .copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(BuildContext context, String phoneText,
      String cleanPhone, bool canCall) {
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
                      Text("Phone Number",
                          style: AppTextStyles.bodySmall(context)
                              .copyWith(
                              color: AppColors.textSecondary)),
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
                  canCall
                      ? "Call Customer"
                      : "Phone available later",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationCard(BuildContext context, String addressText,
      bool canNavigate, address) {
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
                    style:
                    AppTextStyles.bodyMedium(context).copyWith(
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
                Get.to(
                      () => NavigationPage(
                    destinationLat: address.latitude!,
                    destinationLng: address.longitude!,
                    destinationName: address.formattedAddress ??
                        "Customer Location",
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

  Widget _actionButton(
      BuildContext context, IconData icon, String text) {
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
          Text(text,
              style: AppTextStyles.buttonMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              )),
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
      child: Icon(icon,
          color: color ?? AppColors.secondary,
          size: rs(context, 22)),
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
            Text(title,
                style: AppTextStyles.bodyLarge(context)
                    .copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: rs(context, 10)),
        child,
      ],
    );
  }
}