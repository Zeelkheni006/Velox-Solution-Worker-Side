import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/app_responsive.dart';

enum DividerType { or, simple }

class CustomDivider extends StatelessWidget {
  final DividerType type;
  final double thickness; // max thickness
  final double? width;
  final double? horizontalPadding;
  final Color? color;

  const CustomDivider({
    Key? key,
    required this.type,
    this.thickness = 1,
    this.width,
    this.horizontalPadding,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case DividerType.or:
        return Row(
          children: [
            Expanded(
              child: _buildGradientLine(context, leftToRight: true),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 8)),
              child: Text(
                'OR',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: rs(context, 14),
                ),
              ),
            ),
            Expanded(
              child: _buildGradientLine(context, leftToRight: false),
            ),
          ],
        );

      case DividerType.simple:
        return Divider(
          color: color ?? AppColors.grey,
          thickness: thickness,
          indent: horizontalPadding != null ? rs(context, horizontalPadding!) : 0,
          endIndent: horizontalPadding != null ? rs(context, horizontalPadding!) : 0,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGradientLine(BuildContext context, {required bool leftToRight}) {
    return Container(
      height: thickness,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: leftToRight ? Alignment.centerLeft : Alignment.centerRight,
          end: leftToRight ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            color?.withOpacity(0.4) ?? AppColors.grey.withOpacity(0.4),
            color?.withOpacity(0.7) ?? AppColors.grey.withOpacity(0.7),
            color ?? AppColors.grey,
          ],
          stops: const [0, 0.5, 1],
        ),
      ),
    );
  }
}
