import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:apilearning/core/constants/app_colors.dart';

class UpcomingOrderShimmerItem extends StatelessWidget {
  const UpcomingOrderShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.greyLight,
      highlightColor: AppColors.white.withOpacity(0.6),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top Row: Order ID + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(width: 130, height: 16),
                _shimmerBox(width: 75, height: 24, radius: 20),
              ],
            ),
            const SizedBox(height: 12),

            /// Customer Name
            _shimmerBox(width: 170, height: 14),
            const SizedBox(height: 8),

            /// Address line 1
            _shimmerBox(width: double.infinity, height: 12),
            const SizedBox(height: 6),

            /// Address line 2
            _shimmerBox(width: 200, height: 12),
            const SizedBox(height: 14),

            /// Bottom Row: Price + Scheduled Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(width: 85, height: 16),
                _shimmerBox(width: 90, height: 12),
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