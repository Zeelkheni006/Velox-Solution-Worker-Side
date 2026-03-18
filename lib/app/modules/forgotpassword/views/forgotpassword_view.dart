import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../../../../core/utils/custom_textField.dart';
import '../controllers/forgotpassword_controller.dart';

class ForgotpasswordView extends GetView<ForgotpasswordController> {
  const ForgotpasswordView({super.key});

  @override
  Widget build(BuildContext context) {

    final pinTheme = PinTheme(
      width: rs(context, 56),
      height: rs(context, 56),
      textStyle: AppTextStyles.heading3(context)
          .copyWith(color: AppColors.primary),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Text("Hello")
      ),
    );
  }
}
