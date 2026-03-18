import 'package:apilearning/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_assets.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.checkLoginAndNavigate();

    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image(
          image: AssetImage(AppAssets.logo),
          width: 220,
        ),
      ),
    );
  }
}
