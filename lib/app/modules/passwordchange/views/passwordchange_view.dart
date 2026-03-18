import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../../../../core/utils/custom_textField.dart';
import '../controllers/passwordchange_controller.dart';

class PasswordchangeView extends GetView<PasswordchangeController> {
  const PasswordchangeView({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: Text("Change Password", style: AppTextStyles.heading3(context)),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                rs(context, 20),
                rs(context, 20),
                rs(context, 20),
                rs(context, 100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWarningMessage(context),
                  SizedBox(height: rs(context, 20)),

                  _buildLabel(context, 'Current Password'),
                  CustomTextField(
                    controller: controller.currentPasswordController,
                    hintText: '',
                    labelText: 'Enter current password',
                    isPassword: true,
                  ),
                  SizedBox(height: rs(context, 12)),

                  _buildLabel(context, 'New Password'),
                  CustomTextField(
                    controller: controller.newPasswordController,
                    hintText: '',
                    labelText: 'Enter new password',
                    isPassword: true,
                  ),
                  SizedBox(height: rs(context, 12)),

                  _buildLabel(context, 'Confirm New Password'),
                  CustomTextField(
                    controller: controller.confirmPasswordController,
                    hintText: '',
                    labelText: 'Enter confirm password',
                    isPassword: true,
                  ),

                  GetBuilder<PasswordchangeController>(
                    builder: (controller) {
                      if (!controller.showPasswordMismatch) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: EdgeInsets.only(top: rs(context, 8)),
                        child: Text(
                          'Passwords do not match',
                          style: TextStyle(
                            fontSize: rs(context, 12),
                            color: AppColors.error,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: rs(context, 20)),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: rs(context, 20),
            left: rs(context, 20),
            right: rs(context, 20),
            child: _buildSaveButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage(BuildContext context) {
    return CustomContainer(
      padding: EdgeInsets.all(rs(context, 16)),
      backgroundColor: AppColors.warning.withOpacity(0.1),
      borderRadius: BorderRadius.all(AppRadii.md(context)),
      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.warning,
            size: rs(context, 20),
          ),
          SizedBox(width: rs(context, 12)),
          Expanded(
            child: Text(
              'Please note changing password will require you to login again to the app.',
              style: TextStyle(
                fontSize: rs(context, 14),
                color: AppColors.warning,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Obx(() => CustomContainer(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: rs(context, 16),
        horizontal: rs(context, 24),
      ),
      backgroundColor: controller.isLoading.value
          ? AppColors.primary.withOpacity(0.6)
          : AppColors.primary,
      borderRadius: BorderRadius.all(AppRadii.md(context)),
      onTap: controller.isLoading.value
          ? null
          : controller.savePassword,
      text: controller.isLoading.value
          ? "Please wait..."
          : "Save Password",
      textStyle: AppTextStyles.buttonMedium(context).copyWith(
        color: AppColors.white,
      ),
    ));
  }

  Widget _buildLabel(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: rs(context, 6)),
        child: Text(
          title,
          style: AppTextStyles.bodySmall(context).copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}