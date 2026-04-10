import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../controllers/privacypolicy_controller.dart';

class PrivacypolicyView extends GetView<PrivacypolicyController> {
  const PrivacypolicyView({super.key});

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
              onPressed: () => Get.back(result: true),
            ),
          ),
        ),
        title: Text("Privacy Policy", style: AppTextStyles.heading3(context)),
      ),
      body: Obx(() {

        if (!controller.isReady.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            WebViewWidget(controller: controller.webViewController!),
            if (controller.isLoading.value)
              LinearProgressIndicator(
                value: controller.loadingProgress.value / 100,
                backgroundColor: Colors.transparent,
                minHeight: 3,
              ),
          ],
        );
      }),
    );
  }
}