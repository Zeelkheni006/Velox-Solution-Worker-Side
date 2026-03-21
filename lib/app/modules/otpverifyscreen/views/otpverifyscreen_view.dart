import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../controllers/otpverifyscreen_controller.dart';

class OtpverifyscreenView extends GetView<OtpverifyscreenController> {
  const OtpverifyscreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: rs(context, 20),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: rs(context, 24),
            vertical: rs(context, 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ICON
              _buildIcon(context),

              SizedBox(height: rs(context, 12)),

              // TITLE
              _buildTitle(context),

              SizedBox(height: rs(context, 20)),

              // OTP FIELDS
              _buildOtpFields(context),

              SizedBox(height: rs(context, 16)),

              // RESEND WIDGET
              _buildResendWidget(context),

              SizedBox(height: rs(context, 24)),

              // VERIFY BUTTON
              _buildVerifyButton(context),

              SizedBox(height: rs(context, 24)),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== ICON ====================
  Widget _buildIcon(BuildContext context) {
    return Center(
      child: CustomContainer(
        width: rs(context, 100),
        height: rs(context, 100),
        backgroundColor: AppColors.secondary.withOpacity(0.12),
        borderRadius: BorderRadius.all(AppRadii.xl(context)),
        child: Icon(
          Icons.mark_email_unread_rounded,
          size: rs(context, 48),
          color: AppColors.secondary,
        ),
      ),
    );
  }

  // ==================== TITLE ====================
  Widget _buildTitle(BuildContext context) {
    final credential = controller.credential;
    return Column(
      children: [
        Text(
          "Verify OTP",
          textAlign: TextAlign.center,
          style: AppTextStyles.heading3(context).copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: rs(context, 8)),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: "We sent a 6-digit OTP to\n"),
              TextSpan(
                text: credential,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== OTP FIELDS ====================
  Widget _buildOtpFields(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) => _buildSingleOtpBox(context, index)),
    );
  }

  Widget _buildSingleOtpBox(BuildContext context, int index) {
    return Obx(() {
      final isFilled = controller.otpValues[index].isNotEmpty;
      final isFocused = controller.focusedIndex.value == index;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: rs(context, 48),
        height: rs(context, 50),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(AppRadii.md(context)),
          border: Border.all(
            color: isFocused
                ? AppColors.secondary
                : isFilled
                ? AppColors.secondary.withOpacity(0.5)
                : AppColors.primary.withOpacity(0.2),
            width: isFocused ? 2.0 : 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Invisible text field for input
            TextField(
              controller: controller.otpControllers[index],
              focusNode: controller.focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              cursorColor: AppColors.primary,
              style: AppTextStyles.heading3(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (val) => controller.onOtpChanged(val, index),
              onTap: () => controller.focusedIndex.value = index,
            ),
          ],
        ),
      );
    });
  }

  // ==================== RESEND OTP ====================
  Widget _buildResendWidget(BuildContext context) {
    return Obx(() {
      if (controller.isResending.value) {
        return Center(
          child: SizedBox(
            height: rs(context, 20),
            width: rs(context, 20),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      }

      return GestureDetector(
        onTap: controller.canResend.value ? controller.resendOtp : null,
        child: Center(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodySmall(context),
              children: [
                TextSpan(
                  text: "Didn't receive code? ",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                TextSpan(
                  text: controller.canResend.value
                      ? 'Resend'
                      : 'Resend in ${controller.timerDisplay}',
                  style: TextStyle(
                    color: controller.canResend.value
                        ? AppColors.primary
                        : AppColors.grey,
                    fontWeight: controller.canResend.value
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ==================== VERIFY BUTTON ====================
  Widget _buildVerifyButton(BuildContext context) {
    return Obx(() {
      final isComplete = controller.isOtpComplete.value;
      final isLoading = controller.isLoading.value;

      return CustomContainer(
        height: rs(context, 56),
        backgroundColor: isComplete ? AppColors.primary : AppColors.primary.withOpacity(0.4),
        borderRadius: BorderRadius.all(AppRadii.md(context)),
        boxShadow: isComplete && !isLoading
            ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: rs(context, 16),
            offset: Offset(0, rs(context, 8)),
          ),
        ]
            : [],
        onTap: (isComplete && !isLoading) ? controller.verifyOtp : null,
        child: isLoading
            ? Center(
          child: SizedBox(
            height: rs(context, 24),
            width: rs(context, 24),
            child: CircularProgressIndicator(
              color: AppColors.white,
              strokeWidth: 2.5,
            ),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Verify & Login",
              style: AppTextStyles.buttonLarge(context).copyWith(
                color: AppColors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    });
  }
}