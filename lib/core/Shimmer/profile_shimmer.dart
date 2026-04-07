import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/app_responsive.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // ── Header Shimmer ──
            _buildHeaderShimmer(context),
            SizedBox(height: rs(context, 12)),

            // ── Quick Actions Shimmer ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
              child: _buildQuickActionsShimmer(context),
            ),
            SizedBox(height: rs(context, 12)),

            // ── Settings Section Shimmer ──
            _buildSettingsSectionShimmer(context),
            SizedBox(height: rs(context, 12)),

            // ── Logout Button Shimmer ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 20)),
              child: _shimmerBox(
                width: double.infinity,
                height: rs(context, 50),
                radius: rs(context, 12),
              ),
            ),
            SizedBox(height: rs(context, 24)),
          ],
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeaderShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: rs(context, 28),
        horizontal: rs(context, 20),
      ),
      child: Column(
        children: [
          // Avatar circle
          _shimmerCircle(radius: rs(context, 52)),
          SizedBox(height: rs(context, 14)),

          // Name
          _shimmerBox(width: rs(context, 160), height: rs(context, 18)),
          SizedBox(height: rs(context, 8)),

          // Email
          _shimmerBox(width: rs(context, 200), height: rs(context, 13)),
          SizedBox(height: rs(context, 10)),

          // Phone badge
          _shimmerBox(
            width: rs(context, 130),
            height: rs(context, 30),
            radius: rs(context, 20),
          ),
        ],
      ),
    );
  }

  // ── Quick Actions ──
  Widget _buildQuickActionsShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          _shimmerBox(width: rs(context, 120), height: rs(context, 16)),
          SizedBox(height: rs(context, 14)),

          // Two action buttons
          Row(
            children: [
              Expanded(
                child: _shimmerBox(
                  width: double.infinity,
                  height: rs(context, 72),
                  radius: rs(context, 12),
                ),
              ),
              SizedBox(width: rs(context, 12)),
              Expanded(
                child: _shimmerBox(
                  width: double.infinity,
                  height: rs(context, 72),
                  radius: rs(context, 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Settings ──
  Widget _buildSettingsSectionShimmer(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.all(rs(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          _shimmerBox(width: rs(context, 80), height: rs(context, 16)),
          SizedBox(height: rs(context, 16)),

          // 4 setting tiles
          ...List.generate(4, (index) => _buildSettingTileShimmer(context)),
        ],
      ),
    );
  }

  Widget _buildSettingTileShimmer(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 16)),
      child: Row(
        children: [
          // Icon box
          _shimmerBox(
            width: rs(context, 38),
            height: rs(context, 38),
            radius: rs(context, 10),
          ),
          SizedBox(width: rs(context, 14)),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(width: rs(context, 140), height: rs(context, 14)),
                SizedBox(height: rs(context, 6)),
                _shimmerBox(width: rs(context, 200), height: rs(context, 11)),
              ],
            ),
          ),

          // Chevron
          _shimmerBox(
            width: rs(context, 18),
            height: rs(context, 18),
            radius: rs(context, 4),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──
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

  Widget _shimmerCircle({required double radius}) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}