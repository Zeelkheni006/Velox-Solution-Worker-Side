import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_radius.dart';
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
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppColors.secondary,
                  strokeWidth: 3,
                ),
                SizedBox(height: rs(context, 16)),
                Text(
                  "Loading your history...",
                  style: AppTextStyles.bodySmall(context),
                ),
              ],
            ),
          );
        }

        if (controller.leaveList.isEmpty) {
          return _emptyState(context);
        }

        return _leaveHistoryList(context);
      }),
    );
  }

  /// 🔹 EMPTY STATE
  Widget _emptyState(BuildContext context) {
    return Center(
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
        ],
      ),
    );
  }

  /// 🔹 LEAVE HISTORY LIST
  Widget _leaveHistoryList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(rs(context, 20)),
      itemCount: controller.leaveList.length,
      itemBuilder: (context, index) {
        final leave = controller.leaveList[index];
        final start = leave['start_datetime'];
        final end = leave['end_datetime'];
        final status = leave['status'];

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

  /// 🔹 LEAVE HISTORY CARD - TIMELINE STYLE
  Widget _leaveHistoryCard(
      BuildContext context, {
        required String startDate,
        required String endDate,
        required String status,
        required int index,
      }) {
    // Status colors and icons
    Color statusColor = AppColors.warning;
    IconData statusIcon = Icons.schedule_rounded;
    String statusLabel = status;

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
              /// Status Badge
              CustomContainer(
                width: rs(context, 48),
                height: rs(context, 48),
                backgroundColor: statusColor,
                borderRadius: BorderRadius.circular(rs(context, 24)), // make it circle
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
                  offset: Offset(0, 4),
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
                            backgroundColor: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(rs(context, 10)),
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
                                  style: AppTextStyles.bodyMedium(context).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatTime(startDate),
                                  style: AppTextStyles.caption(context).copyWith(
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(vertical: rs(context, 8)),
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
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(rs(context, 10)),
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
                                  style: AppTextStyles.bodyMedium(context).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatTime(endDate),
                                  style: AppTextStyles.caption(context).copyWith(
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

  /// 🔹 DURATION INFO
  Widget _durationInfo(BuildContext context, String startDate, String endDate) {
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    final duration = end.difference(start);

    final days = duration.inDays;
    final hours = duration.inHours % 24;

    String durationText = '';
    if (days > 0) {
      durationText = '$days day${days > 1 ? 's' : ''}';
      if (hours > 0) {
        durationText += ', $hours hr${hours > 1 ? 's' : ''}';
      }
    } else if (hours > 0) {
      durationText = '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      final minutes = duration.inMinutes;
      durationText = '$minutes minute${minutes > 1 ? 's' : ''}';
    }

    return CustomContainer(
      backgroundColor: AppColors.primary.withOpacity(0.05),
      borderRadius: BorderRadius.circular(rs(context, 10)),
      padding: EdgeInsets.symmetric(
        horizontal: rs(context, 10),
        vertical: rs(context, 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timelapse_rounded,
            size: rs(context, 16),
            color: AppColors.primary,
          ),
          SizedBox(width: rs(context, 6)),
          Text(
            "Duration: $durationText",
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