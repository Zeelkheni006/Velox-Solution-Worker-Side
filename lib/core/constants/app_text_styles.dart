import 'package:flutter/material.dart';
import '../utils/app_responsive.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle heading1(BuildContext context) => TextStyle(
    fontSize: rs(context, 32),
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2(BuildContext context) => TextStyle(
    fontSize: rs(context, 28),
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle heading3(BuildContext context) => TextStyle(
    fontSize: rs(context, 24),
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle heading4(BuildContext context) => TextStyle(
    fontSize: rs(context, 22),
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
    fontSize: rs(context, 18),
    color: AppColors.textPrimary,
  );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
    fontSize: rs(context, 16),
    color: AppColors.textPrimary,
  );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
    fontSize: rs(context, 14),
    color: AppColors.textSecondary,
  );

  static TextStyle caption(BuildContext context) => TextStyle(
    fontSize: rs(context, 12),
    color: AppColors.textSecondary,
  );

  static TextStyle buttonLarge(BuildContext context) => TextStyle(
    fontSize: rs(context, 18),
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle buttonMedium(BuildContext context) => TextStyle(
    fontSize: rs(context, 16),
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle buttonSmall(BuildContext context) => TextStyle(
    fontSize: rs(context, 14),
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle primaryButtonText(BuildContext context) => buttonMedium(context).copyWith(color: AppColors.white);

  static TextStyle secondaryButtonText(BuildContext context) => buttonMedium(context).copyWith(color: AppColors.primary);
}
