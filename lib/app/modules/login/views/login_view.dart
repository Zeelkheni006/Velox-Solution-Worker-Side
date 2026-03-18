import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../../../../core/utils/custom_divider.dart';
import '../../../../core/utils/custom_textField.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: rs(context, 24),
              vertical: rs(context, 16),
            ),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ANIMATED LOGO CONTAINER
                  _buildLogo(context),

                  SizedBox(height: rs(context, 32)),

                  // WELCOME TEXT
                  _buildWelcomeText(context),

                  SizedBox(height: rs(context, 32)),

                  // EMAIL / PHONE INPUT
                  _buildCredentialInput(context),

                  SizedBox(height: rs(context, 20)),

                  // PASSWORD INPUT
                  _buildPasswordInput(context),

                  // FORGOT PASSWORD
                  _buildForgotPassword(context),

                  SizedBox(height: rs(context, 12)),

                  // LOGIN BUTTON
                  _buildLoginButton(context),

                  SizedBox(height: rs(context, 24)),

                  // DIVIDER WITH "OR"
                  CustomDivider(
                    type: DividerType.or,
                    thickness: rs(context, 1),
                    color: AppColors.primary.withOpacity(0.3),
                  ),

                  SizedBox(height: rs(context, 24)),

                  // OTP LOGIN BUTTON
                  _buildOTPButton(context),

                  SizedBox(height: rs(context, 32)),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== LOGO ====================
  Widget _buildLogo(BuildContext context) {
    return Center(
      child: CustomContainer(
        width: rs(context, 100),
        height: rs(context, 100),
        backgroundColor: AppColors.primary,
        borderRadius: BorderRadius.all(AppRadii.xl(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: rs(context, 20),
            offset: Offset(0, rs(context, 10)),
          ),
        ],
        child: Icon(
          Icons.business_center_rounded,
          size: rs(context, 50),
          color: AppColors.secondary,
        ),
      ),
    );
  }

  // ==================== WELCOME TEXT ====================
  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      children: [
        Text(
          "Welcome Back",
          textAlign: TextAlign.center,
          style: AppTextStyles.heading1(context).copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: rs(context, 8)),
        Text(
          "Sign in to continue to your account",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ==================== CREDENTIAL INPUT ====================
  Widget _buildCredentialInput(BuildContext context) {
    return Obx(() {
      return CustomTextField(
        controller: controller.credentialController,
        labelText: "Email or Phone",
        hintText: controller.isPhoneNumber.value
            ? '9876543210'
            : 'example@email.com',
        keyboardType: controller.isPhoneNumber.value
            ? TextInputType.phone
            : TextInputType.emailAddress,
        onChanged: controller.checkInputType,
        prefixWidget: Icon(
          controller.isPhoneNumber.value
              ? Icons.phone_android_rounded
              : Icons.email_outlined,
          color: AppColors.primary,
          size: rs(context, 22),
        ),
      );
    });
  }

  // ==================== PASSWORD INPUT ====================
  Widget _buildPasswordInput(BuildContext context) {
    return CustomTextField(
      controller: controller.passwordController,
      labelText: "Password",
      hintText: '••••••••',
      isPassword: true,
      prefixWidget: Icon(
        Icons.lock_outline_rounded,
        color: AppColors.primary,
        size: rs(context, 22),
      ),
    );
  }

  // ==================== FORGOT PASSWORD ====================
  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: CustomContainer(
        onTap: () {
          _showForgotPasswordDialog(context);
        },
        padding: EdgeInsets.symmetric(
          horizontal: rs(context, 8),
          vertical: rs(context, 4),
        ),
        backgroundColor: Colors.transparent,
        borderRadius: BorderRadius.circular(rs(context, 6)),
        child: Text(
          "Forgot Password?",
          style: AppTextStyles.bodySmall(context).copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
    );
  }

  // ==================== LOGIN BUTTON ====================
  Widget _buildLoginButton(BuildContext context) {
    return Obx(() {
      return CustomContainer(
        height: rs(context, 56),
        backgroundColor: AppColors.primary,
        borderRadius: BorderRadius.all(AppRadii.md(context)),
        boxShadow: controller.isLoading.value
            ? []
            : [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: rs(context, 16),
            offset: Offset(0, rs(context, 8)),
          ),
        ],
        onTap: controller.isLoading.value ? null : controller.loginWithPassword,
        child: controller.isLoading.value
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
              "Login",
              style: AppTextStyles.buttonLarge(context).copyWith(
                color: AppColors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: rs(context, 8)),
            Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.white,
              size: rs(context, 20),
            ),
          ],
        ),
      );
    });
  }

  // ==================== OTP BUTTON ====================
  Widget _buildOTPButton(BuildContext context) {
    return Obx(() {
      final isActive = controller.isCredentialFilled.value;

      return CustomContainer(
        height: rs(context, 56),
        backgroundColor:
        isActive ? AppColors.secondary.withOpacity(0.8) : Colors.grey.shade300,
        borderRadius: BorderRadius.all(AppRadii.md(context)),
        border: Border.all(
          color: isActive ? AppColors.secondary : Colors.grey,
          width: 2,
        ),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.2),
            blurRadius: rs(context, 12),
            offset: Offset(0, rs(context, 6)),
          ),
        ]
            : [],
        onTap: isActive ? controller.loginWithOTP : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_rounded,
              color: isActive ? AppColors.white : Colors.grey,
              size: rs(context, 20),
            ),
            SizedBox(width: rs(context, 12)),
            Text(
              "Login with OTP",
              style: AppTextStyles.buttonLarge(context).copyWith(
                color: isActive ? AppColors.white : Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ==================== FORGOT PASSWORD DIALOG ====================
  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadii.lg(context)),
        ),
        child: Padding(
          padding: EdgeInsets.all(rs(context, 24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.secondary,
                    size: rs(context, 28),
                  ),
                  SizedBox(width: rs(context, 12)),
                  Text(
                    "Reset Password",
                    style: AppTextStyles.heading3(context).copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: rs(context, 16)),
              Text(
                "Enter your email address and we'll send you a link to reset your password.",
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: rs(context, 24)),
              CustomTextField(
                controller: emailController,
                labelText: "Email Address",
                hintText: "example@email.com",
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: rs(context, 24)),
              Row(
                children: [
                  Expanded(
                    child: CustomContainer(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: rs(context, 14),
                      ),
                      backgroundColor: Colors.transparent,
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.all(AppRadii.sm(context)),
                      onTap: () => Get.back(),
                      centerText: true,
                      text: "Cancel",
                      textStyle: AppTextStyles.buttonMedium(context).copyWith(
                        color: AppColors.primary,
                      ),
                    )
                  ),
                  SizedBox(width: rs(context, 12)),
                  Expanded(
                    child: CustomContainer(
                      width: double.infinity,
                      height: rs(context, 50),
                      backgroundColor: AppColors.secondary,
                      borderRadius: BorderRadius.all(AppRadii.sm(context)),
                      padding: EdgeInsets.symmetric(vertical: rs(context, 14)),
                      onTap: () {

                      },
                      text: "Send Link",
                      textStyle: AppTextStyles.buttonMedium(context).copyWith(
                        color: AppColors.white,
                      ),
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}