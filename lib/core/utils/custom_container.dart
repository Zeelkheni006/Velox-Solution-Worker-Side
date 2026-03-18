import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../utils/app_responsive.dart';

class CustomContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Widget? child;
  final String? text;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool centerText;
  final BoxBorder? border;
  final BorderRadiusGeometry? borderRadius;
  final DecorationImage? backgroundImage;
  final List<BoxShadow>? boxShadow;

  const CustomContainer({
    Key? key,
    this.width,
    this.height,
    this.backgroundColor = AppColors.textWhite,
    this.child,
    this.text,
    this.textStyle,
    this.padding,
    this.onTap,
    this.centerText = true,
    this.border,
    this.borderRadius,
    this.backgroundImage,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.all(AppRadii.md(context)),
          border: border,
          image: backgroundImage,
          boxShadow: boxShadow,
        ),
        child: child ?? _buildTextChild(context),
      ),
    );
  }

  Widget _buildTextChild(BuildContext context) {
    if (text == null) return const SizedBox.shrink();

    final defaultTextStyle = TextStyle(
      color: AppColors.textWhite,
      fontWeight: FontWeight.bold,
      fontSize: rs(context, 18),
    );

    final styledText = Text(
      text!,
      style: defaultTextStyle.merge(textStyle),
    );

    return centerText ? Center(child: styledText) : styledText;
  }
}
