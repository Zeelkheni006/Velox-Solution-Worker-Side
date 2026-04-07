import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../../../../core/utils/custom_divider.dart';
import '../controllers/leavehistory_controller.dart';

class LeavehistoryView extends GetView<LeavehistoryController> {
  const LeavehistoryView({super.key});

  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString);
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatTime(String isoString) {
    final date = DateTime.parse(isoString);
    return DateFormat('hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      /// 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.all(rs(context, 8)),
          child: CircleAvatar(
            radius: rs(context, 20),
            backgroundColor: AppColors.black.withOpacity(0.15),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: AppColors.black,
                size: rs(context, 18),
              ),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: Text(
          "Leave History",
          style: AppTextStyles.heading3(context).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      /// 🔹 BODY
      body: Obx(() {
        /// 🔹 SHIMMER LOADING
        if (controller.isLoading.value) {
          return _shimmerView(context);
        }

        /// 🔹 EMPTY STATE (with Pull-to-Refresh)
        if (controller.leaveList.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refreshHistory,
            color: AppColors.secondary,
            backgroundColor: AppColors.white,
            displacement: 40,
            strokeWidth: 2.5,
            child: _emptyState(context),
          );
        }

        /// 🔹 LIST (with Pull-to-Refresh)
        return RefreshIndicator(
          onRefresh: controller.refreshHistory,
          color: AppColors.secondary,
          backgroundColor: AppColors.white,
          displacement: 40,
          strokeWidth: 2.5,
          child: _leaveHistoryList(context),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────
  /// 🔹 SHIMMER LOADING VIEW
  // ─────────────────────────────────────────────────
  Widget _shimmerView(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(rs(context, 20)),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: List.generate(5, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: rs(context, 10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Timeline circle shimmer
                Column(
                  children: [
                    _ShimmerBox(
                      width: rs(context, 48),
                      height: rs(context, 48),
                      borderRadius: rs(context, 24),
                    ),
                    if (index < 4)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: rs(context, 4),
                        ),
                        child: _ShimmerBox(
                          width: 2,
                          height: rs(context, 60),
                          borderRadius: 4,
                        ),
                      ),
                  ],
                ),
                SizedBox(width: rs(context, 8)),

                /// Card shimmer
                Expanded(
                  child: _ShimmerBox(
                    width: double.infinity,
                    height: rs(context, 160),
                    borderRadius: rs(context, 20),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  /// 🔹 EMPTY STATE
  // ─────────────────────────────────────────────────
  Widget _emptyState(BuildContext context) {
    return SingleChildScrollView(
      /// ⚠️ AlwaysScrollableScrollPhysics: Required so RefreshIndicator
      /// triggers even when content doesn't overflow the screen
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomContainer(
              padding: EdgeInsets.all(rs(context, 32)),
              backgroundColor: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(1000),
              child: Icon(
                Icons.history_rounded,
                size: rs(context, 80),
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            SizedBox(height: rs(context, 24)),
            Text(
              "No Leave History",
              style: AppTextStyles.heading4(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: rs(context, 8)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 48)),
              child: Text(
                "You haven't made any leave requests yet",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(context),
              ),
            ),
            SizedBox(height: rs(context, 24)),

            /// Pull to refresh hint
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_downward_rounded,
                  size: rs(context, 14),
                  color: AppColors.grey,
                ),
                SizedBox(width: rs(context, 4)),
                Text(
                  "Pull down to refresh",
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  /// 🔹 LEAVE HISTORY LIST
  // ─────────────────────────────────────────────────
  Widget _leaveHistoryList(BuildContext context) {
    return ListView.builder(
      /// ⚠️ AlwaysScrollableScrollPhysics: Required for RefreshIndicator
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(rs(context, 20)),
      itemCount: controller.leaveList.length + 1, // +1 for bottom hint
      itemBuilder: (context, index) {
        /// Pull to refresh hint at bottom
        if (index == controller.leaveList.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: rs(context, 12)),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    size: rs(context, 14),
                    color: AppColors.grey,
                  ),
                  SizedBox(width: rs(context, 4)),
                  Text(
                    "Pull down to refresh",
                    style: AppTextStyles.caption(context).copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final leave = controller.leaveList[index];
        final start = leave['start_datetime'] as String;
        final end = leave['end_datetime'] as String;
        final status = leave['status'] as String;

        return _leaveHistoryCard(
          context,
          startDate: start,
          endDate: end,
          status: status,
          index: index,
        );
      },
    );
  }

  // ─────────────────────────────────────────────────
  /// 🔹 LEAVE HISTORY CARD - TIMELINE STYLE
  // ─────────────────────────────────────────────────
  Widget _leaveHistoryCard(
      BuildContext context, {
        required String startDate,
        required String endDate,
        required String status,
        required int index,
      }) {
    Color statusColor = AppColors.warning;
    IconData statusIcon = Icons.schedule_rounded;
    final String statusLabel = status;

    if (status == "APPROVED") {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
    } else if (status == "REJECTED") {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel_rounded;
    } else if (status == "PENDING") {
      statusColor = AppColors.warning;
      statusIcon = Icons.access_time_rounded;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔸 TIMELINE INDICATOR
          Column(
            children: [
              /// Status Badge Circle
              CustomContainer(
                width: rs(context, 48),
                height: rs(context, 48),
                backgroundColor: statusColor,
                borderRadius: BorderRadius.circular(rs(context, 24)),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                child: Icon(
                  statusIcon,
                  color: AppColors.white,
                  size: rs(context, 24),
                ),
              ),

              /// Connecting Line (skip for last item)
              if (index < controller.leaveList.length - 1)
                Container(
                  width: 2,
                  height: rs(context, 60),
                  margin: EdgeInsets.symmetric(vertical: rs(context, 4)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        statusColor.withOpacity(0.5),
                        AppColors.greyLight,
                      ],
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: rs(context, 8)),

          /// 🔸 LEAVE DETAILS CARD
          Expanded(
            child: CustomContainer(
              backgroundColor: AppColors.white,
              borderRadius: BorderRadius.circular(rs(context, 20)),
              padding: EdgeInsets.all(rs(context, 12)),
              border: Border.all(
                color: statusColor.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// STATUS BADGE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomContainer(
                        padding: EdgeInsets.symmetric(
                          horizontal: rs(context, 12),
                          vertical: rs(context, 6),
                        ),
                        backgroundColor: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(rs(context, 20)),
                        child: Text(
                          statusLabel,
                          style: AppTextStyles.caption(context).copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      /// Duration chip
                      _durationChip(context, startDate, endDate),
                    ],
                  ),

                  SizedBox(height: rs(context, 12)),

                  /// DATE RANGE SECTION
                  CustomContainer(
                    padding: EdgeInsets.all(rs(context, 10)),
                    backgroundColor: AppColors.surface,
                    borderRadius: BorderRadius.circular(rs(context, 12)),
                    child: Column(
                      children: [
                        /// START DATE
                        Row(
                          children: [
                            CustomContainer(
                              padding: EdgeInsets.all(rs(context, 8)),
                              backgroundColor:
                              AppColors.secondary.withOpacity(0.1),
                              borderRadius:
                              BorderRadius.circular(rs(context, 10)),
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: AppColors.secondary,
                                size: rs(context, 18),
                              ),
                            ),
                            SizedBox(width: rs(context, 12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "From",
                                    style: AppTextStyles.caption(context),
                                  ),
                                  SizedBox(height: rs(context, 2)),
                                  Text(
                                    _formatDate(startDate),
                                    style: AppTextStyles.bodyMedium(context)
                                        .copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(startDate),
                                    style:
                                    AppTextStyles.caption(context).copyWith(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: rs(context, 8)),
                          child: CustomDivider(
                            type: DividerType.simple,
                            color: AppColors.greyLight,
                            thickness: 1,
                          ),
                        ),

                        /// END DATE
                        Row(
                          children: [
                            CustomContainer(
                              padding: EdgeInsets.all(rs(context, 8)),
                              backgroundColor:
                              AppColors.primary.withOpacity(0.1),
                              borderRadius:
                              BorderRadius.circular(rs(context, 10)),
                              child: Icon(
                                Icons.stop_rounded,
                                color: AppColors.primary,
                                size: rs(context, 18),
                              ),
                            ),
                            SizedBox(width: rs(context, 12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "To",
                                    style: AppTextStyles.caption(context),
                                  ),
                                  SizedBox(height: rs(context, 2)),
                                  Text(
                                    _formatDate(endDate),
                                    style: AppTextStyles.bodyMedium(context)
                                        .copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(endDate),
                                    style:
                                    AppTextStyles.caption(context).copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  /// 🔹 DURATION CHIP (inline, replaces unused _durationInfo method)
  // ─────────────────────────────────────────────────
  Widget _durationChip(
      BuildContext context, String startDate, String endDate) {
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    final duration = end.difference(start);

    final days = duration.inDays;
    final hours = duration.inHours % 24;

    String durationText;
    if (days > 0) {
      durationText = '$days d${hours > 0 ? ', ${hours}h' : ''}';
    } else if (hours > 0) {
      durationText = '${duration.inHours} hr${duration.inHours > 1 ? 's' : ''}';
    } else {
      final minutes = duration.inMinutes;
      durationText = '${minutes} min';
    }

    return CustomContainer(
      padding: EdgeInsets.symmetric(
        horizontal: rs(context, 8),
        vertical: rs(context, 4),
      ),
      backgroundColor: AppColors.primary.withOpacity(0.05),
      borderRadius: BorderRadius.circular(rs(context, 10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timelapse_rounded,
            size: rs(context, 13),
            color: AppColors.primary,
          ),
          SizedBox(width: rs(context, 4)),
          Text(
            durationText,
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// 🔹 SHIMMER BOX WIDGET (No external package — pure Flutter animation)
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor =
    isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);
    final shimmerColor =
    isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, shimmerColor, baseColor],
              stops: [
                (_animation.value - 0.5).clamp(0.0, 1.0),
                (_animation.value).clamp(0.0, 1.0),
                (_animation.value + 0.5).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}