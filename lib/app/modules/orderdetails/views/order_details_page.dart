import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../../../../core/utils/custome_snakbar.dart';
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
              // ── Scrollable content ──────────────────────────────────
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: rs(context, 90)),
                  child: Column(
                    children: [
                      /// ================= HERO HEADER =================
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
                              child: _contactCard(
                                context,
                                phoneText,
                                cleanPhone,
                                canCall,
                              ),
                            ),
                            SizedBox(height: rs(context, 20)),
                            _section(
                              context,
                              title: "Service Location",
                              icon: Icons.location_on_rounded,
                              child: _locationCard(
                                context,
                                addressText,
                                canNavigate,
                                address,
                              ),
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
                if (controller.isOtpVerified.value) {
                  return Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CustomContainer(
                      padding: EdgeInsets.all(rs(context, 16)),
                      backgroundColor: AppColors.surface,
                      borderRadius: AppRadii.button(context),
                      onTap: () async {
                        if (controller.capturedImage.value == null) {
                          final captured = await controller.captureImage();
                          if (captured) {
                            _showImagePreviewBottomSheet(context, controller);
                          }
                        } else {
                          _showImagePreviewBottomSheet(context, controller);
                        }
                      },
                      child: _actionButton(
                        context,
                        controller.capturedImage.value != null ? Icons.check_circle : Icons.camera_alt_rounded,
                        controller.capturedImage.value != null ? "Complete Order" : "Capture & Complete Order",
                      ),
                    ),
                  );
                }

                if (controller.showOtpField.value) {
                  // Use a post frame callback to ensure we don't show multiple bottom sheets
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!(Get.isBottomSheetOpen == true) && !controller.isOtpVerified.value) {
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
              })
            ],
          ),
        );
      },
    );
  }

  void _showOtpBottomSheet(
      BuildContext context,
      OrderDetailsController controller,
      ) {
    // Prevent multiple bottom sheets
    if (Get.isBottomSheetOpen == true) return;

    final RxList<String> digits = <String>[].obs;

    // Show bottom sheet without affecting navigation stack
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
            // Allow back button only in certain conditions
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

            // ✅ CLOSE ONLY BOTTOM SHEET, NOT THE PAGE
            if (controller.isOtpVerified.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // This will only close the bottom sheet, not the page
                Navigator.of(sheetContext).pop();
              });
              return const SizedBox.shrink();
            }

            // Close when timer expires
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
                  // Handle
                  CustomContainer(
                    width: rs(context, 40),
                    height: rs(context, 4),
                    backgroundColor: AppColors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(rs(context, 10)),
                  ),

                  SizedBox(height: rs(context, 16)),

                  // Header with timer
                  Row(
                    children: [
                      CustomContainer(
                        padding: EdgeInsets.all(rs(context, 10)),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(rs(context, 100)),
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
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Timer chip
                      CustomContainer(
                        padding: EdgeInsets.symmetric(
                          horizontal: rs(context, 10),
                          vertical: rs(context, 6),
                        ),
                        backgroundColor: AppColors.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(rs(context, 20)),
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
                              style: AppTextStyles.bodySmall(context).copyWith(
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

                  // OTP Dots
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
                            borderRadius: BorderRadius.circular(rs(context, 10)),
                            border: Border.all(
                              color: filled
                                  ? AppColors.primary
                                  : isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary.withOpacity(0.25),
                              width: filled || isActive ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: filled
                                ? CustomContainer(
                              width: rs(context, 12),
                              height: rs(context, 12),
                              backgroundColor: AppColors.primary,
                              borderRadius: BorderRadius.circular(rs(context, 12)),
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

                  // Number Pad
                  _buildNumberPad(context, digits, controller, sheetContext),
                ],
              ),
            );
          }),
        );
      },
    ).then((_) {
      // Clean up when bottom sheet is closed
      digits.clear();
      controller.otpController.clear();
      // DON'T pop anything here - just clean up
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
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 5)),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(rs(context, 14)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(rs(context, 14)),
                      onTap: () async {
                        // Don't process taps if OTP is already verified
                        if (controller.isOtpVerified.value) {
                          // Close only bottom sheet, not the page
                          Navigator.of(sheetContext).pop();
                          return;
                        }

                        if (isDel) {
                          if (digits.isNotEmpty) {
                            digits.removeLast();
                            controller.otpController.text = digits.join();
                          }
                        } else if (isCancel) {
                          // Cancel button - close only bottom sheet
                          Navigator.of(sheetContext).pop();
                        } else {
                          if (digits.length < 6) {
                            digits.add(key);
                            controller.otpController.text = digits.join();

                            if (digits.length == 6) {
                              await Future.delayed(const Duration(milliseconds: 250));
                              await controller.confirmOtp();
                              // Bottom sheet will be closed in confirmOtp method
                              // But ensure we don't pop the page
                            }
                          }
                        }
                      },
                      child: CustomContainer(
                        height: rs(context, 58),
                        backgroundColor: isCancel
                            ? AppColors.error.withOpacity(0.07)
                            : isDel
                            ? AppColors.textSecondary.withOpacity(0.07)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(rs(context, 14)),
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
                              ? Icon(
                            Icons.backspace_outlined,
                            color: AppColors.textSecondary,
                            size: rs(context, 22),
                          )
                              : isCancel
                              ? Text(
                            "Cancel",
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                              : Text(
                            key,
                            style: AppTextStyles.heading4(context).copyWith(
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
      backgroundColor: color.withOpacity(0.12),
      borderRadius: AppRadii.card(context),
      border: Border.all(color: color.withOpacity(0.3)),
      child: Row(
        children: [
          _iconChip(
            context,
            icon: isPaid ? Icons.check_circle : Icons.payments,
            color: color,
          ),
          SizedBox(width: rs(context, 12)),
          Text(
            isPaid ? "Paid Online" : "Collect Cash",
            style: AppTextStyles.bodyMedium(context)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            "₹${order.totalAmount}",
            style: AppTextStyles.heading4(context).copyWith(color: color),
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
                        style: AppTextStyles.bodyMedium(context).copyWith(
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
                  ? () async {
                final uri = Uri.parse(
                  "https://www.google.com/maps/dir/?api=1"
                      "&origin=Current+Location"
                      "&destination=${address.latitude},${address.longitude}"
                      "&travelmode=driving",
                );
                if (!await launchUrl(uri,
                    mode: LaunchMode.externalApplication)) {
                  CustomSnackbar.showError(
                      "Error", "Could not open Google Maps");
                }
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

  void _showImagePreviewBottomSheet(
      BuildContext context,
      OrderDetailsController controller,
      ) {
    if (Get.isBottomSheetOpen ?? false) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (sheetContext) {
        return Obx(() {
          final imageFile = controller.capturedImage.value;

          if (imageFile == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Get.isBottomSheetOpen ?? false) {
                Navigator.of(sheetContext).pop();
              }
            });
            return const SizedBox.shrink();
          }

          return CustomContainer(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              rs(context, 20),
              rs(context, 18),
              rs(context, 20),
              rs(context, 28),
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
                  backgroundColor: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(rs(context, 10)),
                ),

                SizedBox(height: rs(context, 16)),

                Row(
                  children: [
                    CustomContainer(
                      padding: EdgeInsets.all(rs(context, 10)),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                      child: Icon(
                        Icons.camera_alt_rounded,
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
                            "Order Photo",
                            style: AppTextStyles.heading4(context)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Preview before completing order",
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: rs(context, 16)),

                ClipRRect(
                  borderRadius: BorderRadius.circular(rs(context, 16)),
                  child: Image.file(
                    imageFile,
                    width: double.infinity,
                    height: rs(context, 280),
                    fit: BoxFit.cover,
                  ),
                ),

                SizedBox(height: rs(context, 16)),

                Row(
                  children: [

                    Expanded(
                      child: CustomContainer(
                        height: rs(context, 52),
                        onTap: () {
                          controller.deleteCapturedImage();
                          Navigator.of(sheetContext).pop();
                        },
                        backgroundColor: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(rs(context, 14)),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                              size: rs(context, 20),
                            ),
                            SizedBox(width: rs(context, 6)),
                            Text(
                              "Retake",
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: rs(context, 12)),

                    Expanded(
                      flex: 2,
                      child: Obx(() => CustomContainer(
                        height: rs(context, 52),
                        onTap: controller.isLoading.value
                            ? null
                            : () async {
                          Navigator.of(sheetContext).pop();
                          await controller.completeOrder();
                        },
                        backgroundColor: controller.isLoading.value
                            ? AppColors.secondary.withOpacity(0.5)
                            : AppColors.secondary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(rs(context, 14)),
                        child: controller.isLoading.value
                            ? Center(
                          child: SizedBox(
                            width: rs(context, 22),
                            height: rs(context, 22),
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.white,
                              size: rs(context, 20),
                            ),
                            SizedBox(width: rs(context, 6)),
                            Text(
                              "Complete Order",
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }
}