import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_text_styles.dart';
import 'app_responsive.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool isPassword;
  final TextInputType? keyboardType;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final Widget? prefixWidget;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.isPassword = false,
    this.keyboardType,
    this.maxLength,
    this.onChanged,
    this.enabled = true,
    this.prefixWidget,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscure = true;
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focus) {
        setState(() {
          isFocused = focus;
        });
      },
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? obscure : false,
        keyboardType: widget.keyboardType,
        cursorColor: AppColors.primary,
        enabled: widget.enabled,
        style: AppTextStyles.bodyMedium(context).copyWith(
          color: widget.enabled
              ? AppColors.black
              : AppColors.black.withOpacity(0.4),
        ),
        onChanged: widget.onChanged,
        maxLength: widget.maxLength,
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: !widget.enabled
                ? AppColors.grey
                : isFocused
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.6),
            fontSize: rs(context, 14),
          ),

          hintText: widget.hintText,
          hintStyle: AppTextStyles.bodySmall(context),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadii.md(context)),
            borderSide: BorderSide(
              color: AppColors.primary.withOpacity(0.4),
            ),
          ),

          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadii.md(context)),
            borderSide: BorderSide(
              color: AppColors.grey.withOpacity(0.4),
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadii.md(context)),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 1.8,
            ),
          ),

          suffixIcon: widget.isPassword && widget.enabled
              ? GestureDetector(
            onTap: () =>
                setState(() => obscure = !obscure),
            child: Icon(
              obscure
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: AppColors.primary,
            ),
          )
              : null,
        ),
      ),
    );
  }
}
