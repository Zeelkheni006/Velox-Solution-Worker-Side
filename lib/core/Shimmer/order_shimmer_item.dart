import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:apilearning/core/constants/app_colors.dart';

class OrderShimmerItem extends StatelessWidget {
  const OrderShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.greyLight,
      highlightColor: AppColors.surface,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Order ID + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(width: 120, height: 16),
                _shimmerBox(width: 70, height: 24, radius: 20),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Name
            _shimmerBox(width: 180, height: 14),
            const SizedBox(height: 8),

            // Address / Detail line
            _shimmerBox(width: double.infinity, height: 12),
            const SizedBox(height: 6),
            _shimmerBox(width: 220, height: 12),

            const SizedBox(height: 14),

            // Bottom Row: Price + Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(width: 80, height: 16),
                _shimmerBox(width: 60, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}