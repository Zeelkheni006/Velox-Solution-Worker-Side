import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HistoryOrderShimmerItem extends StatelessWidget {
  const HistoryOrderShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Order ID + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(width: 130, height: 16),
                _shimmerBox(width: 75, height: 24, radius: 20),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Name
            _shimmerBox(width: 160, height: 14),
            const SizedBox(height: 8),

            // Address line 1
            _shimmerBox(width: double.infinity, height: 12),
            const SizedBox(height: 6),

            // Address line 2
            _shimmerBox(width: 210, height: 12),
            const SizedBox(height: 14),

            // Divider shimmer
            _shimmerBox(width: double.infinity, height: 1),
            const SizedBox(height: 12),

            // Bottom Row: Price + Completed Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(width: 85, height: 16),
                _shimmerBox(width: 100, height: 12),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}