import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import 'app_responsive.dart';

class FullScreenLoader {
  static bool _isShowing = false;

  static void show({String? message}) {
    if (_isShowing) return;
    _isShowing = true;

    Get.dialog(
      PopScope(
        canPop: false,
        child: Material(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: rs(Get.context!, 40)),
              padding: EdgeInsets.all(rs(Get.context!, 24)),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(rs(Get.context!, 16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: rs(Get.context!, 20),
                    offset: Offset(0, rs(Get.context!, 4)),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Modern Circular Progress
                  SizedBox(
                    width: rs(Get.context!, 50),
                    height: rs(Get.context!, 50),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),

                  if (message != null) ...[
                    SizedBox(height: rs(Get.context!, 16)),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: rs(Get.context!, 15),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    );
  }

  static void hide() {
    if (_isShowing) {
      _isShowing = false;
      Get.back();
    }
  }
}