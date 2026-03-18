import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../core/utils/custom_divider.dart';
import '../../../../core/utils/custome_snakbar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/workerleave_controller.dart';

class WorkerleaveView extends GetView<WorkerleaveController> {
  const WorkerleaveView({super.key});

  String _formatDateTime(String isoString) {
    final date = DateTime.parse(isoString);
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
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

        /// 🔹 BACK BUTTON
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

        /// 🔹 TITLE
        title: Text(
          "Leave Request",
          style: AppTextStyles.heading3(context).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        /// 🔹 RIGHT SIDE HISTORY ICON
        actions: [
          Padding(
            padding: EdgeInsets.all(rs(context, 8)),
            child: IconButton(
              icon: Icon(
                Icons.history_rounded,
                color: AppColors.primary,
                size: rs(context, 26),
              ),
              onPressed: () {
                Get.toNamed(Routes.LEAVEHISTORY);
              },
            ),
          ),
        ],
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
                  "Loading your leave details...",
                  style: AppTextStyles.bodySmall(context),
                ),
              ],
            ),
          );
        }

        /// 🔥 IF STATUS EXISTS → SHOW STATUS UI
        if (controller.showStatusUI.value) {
          return _statusView(context);
        }

        /// 🔥 ELSE → SHOW SUBMIT FORM
        return _leaveFormView(context);
      }),

      /// 🔹 BOTTOM BUTTON (ONLY FOR FORM UI)
      bottomNavigationBar: Obx(() {
        if (controller.showStatusUI.value) {
          return const SizedBox();
        }

        return Container(
          padding: EdgeInsets.fromLTRB(
            rs(context, 20),
            rs(context, 16),
            rs(context, 20),
            rs(context, 24),
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: CustomContainer(
            height: rs(context, 56),
            backgroundColor: AppColors.secondary,
            borderRadius: BorderRadius.circular(rs(context, 16)),
            onTap: controller.submitLeave,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_rounded,
                  color: AppColors.white,
                  size: rs(context, 20),
                ),
                SizedBox(width: rs(context, 10)),
                Text(
                  'Submit Leave Request',
                  style: AppTextStyles.buttonMedium(context),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// 🔹 STATUS UI - MODERN CARD DESIGN
  Widget _statusView(BuildContext context) {
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.schedule_rounded;

    if (controller.statusText.value == "APPROVED") {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
    } else if (controller.statusText.value == "REJECTED") {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel_rounded;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(rs(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🎯 STATUS HEADER CARD
          CustomContainer(
            backgroundColor: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(rs(context, 20)),
            border: Border.all(
              color: statusColor.withOpacity(0.3),
              width: 2,
            ),
            padding: EdgeInsets.all(rs(context, 10)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(rs(context, 8)),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(rs(context, 16)),
                  ),
                  child: Icon(
                    statusIcon,
                    color: AppColors.white,
                    size: rs(context, 32),
                  ),
                ),
                SizedBox(width: rs(context, 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Request Status",
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: statusColor.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: rs(context, 4)),
                      Text(
                        controller.statusText.value,
                        style: AppTextStyles.bodyLarge(context).copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: rs(context, 12)),

          /// 📅 LEAVE DETAILS CARD
          CustomContainer(
            backgroundColor: AppColors.white,
            borderRadius: BorderRadius.circular(rs(context, 20)),
            padding: EdgeInsets.all(rs(context, 20)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Leave Duration",
                  style: AppTextStyles.heading4(context),
                ),

                SizedBox(height: rs(context, 20)),

                /// START DATE ROW
                _infoRow(
                  context,
                  icon: Icons.calendar_today_rounded,
                  iconColor: AppColors.secondary,
                  label: "Start Date",
                  value: _formatDateTime(controller.statusStart.value),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: rs(context, 16)),
                  child: CustomDivider(
                    type: DividerType.simple,
                    color: AppColors.greyLight,
                  ),
                ),

                /// END DATE ROW
                _infoRow(
                  context,
                  icon: Icons.event_rounded,
                  iconColor: AppColors.primary,
                  label: "End Date",
                  value: _formatDateTime(controller.statusEnd.value),
                ),
              ],
            ),
          ),

          SizedBox(height: rs(context, 14)),

          /// 💡 INFO CARD
          CustomContainer(
            backgroundColor: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(rs(context, 16)),
            padding: EdgeInsets.all(rs(context, 16)),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: rs(context, 24),
                ),
                SizedBox(width: rs(context, 12)),
                Expanded(
                  child: Text(
                    controller.statusText.value == "PENDING"
                        ? "Your leave request is under review"
                        : controller.statusText.value == "APPROVED"
                        ? "Your leave has been approved"
                        : "Your leave request was not approved",
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 INFO ROW WIDGET
  Widget _infoRow(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String label,
        required String value,
      }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(rs(context, 10)),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(rs(context, 12)),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: rs(context, 22),
          ),
        ),
        SizedBox(width: rs(context, 14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption(context),
              ),
              SizedBox(height: rs(context, 4)),
              Text(
                value,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔹 LEAVE FORM UI - MODERN DESIGN
  Widget _leaveFormView(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        rs(context, 20),
        rs(context, 20),
        rs(context, 20),
        rs(context, 100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 📌 SECTION HEADER
          Text(
            "Select Leave Period",
            style: AppTextStyles.heading4(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          // SizedBox(height: rs(context, 4)),
          Text(
            "Choose your leave start and end date & time",
            style: AppTextStyles.bodySmall(context),
          ),

          SizedBox(height: rs(context, 12)),

          /// 🎨 DATE TIME CARDS
          Row(
            children: [
              Expanded(
                child: _modernDateTile(
                  context,
                  title: "Start",
                  subtitle: "Date & Time",
                  icon: Icons.play_circle_outline_rounded,
                  iconColor: AppColors.secondary,
                  date: controller.startDate,
                  onTap: () => controller.pickDateTime(context, true),
                ),
              ),
              SizedBox(width: rs(context, 12)),
              Expanded(
                child: _modernDateTile(
                  context,
                  title: "End",
                  subtitle: "Date & Time",
                  icon: Icons.stop_circle_outlined,
                  iconColor: AppColors.primary,
                  date: controller.endDate,
                  onTap: () {
                    if (controller.startDate.value == null) {
                      CustomSnackbar.showError(
                        'Start time required',
                        'Please select start date & time first',
                      );
                      return;
                    }
                    controller.pickDateTime(context, false);
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: rs(context, 14)),

          /// 📝 REASON SECTION
          Text(
            "Reason for Leave",
            style: AppTextStyles.heading4(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          // SizedBox(height: rs(context, 8)),
          Text(
            "Please provide a brief explanation",
            style: AppTextStyles.bodySmall(context),
          ),

          SizedBox(height: rs(context, 12)),

          /// 📄 REASON TEXT FIELD
          CustomContainer(
            backgroundColor: AppColors.white,
            borderRadius: BorderRadius.circular(rs(context, 16)),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rs(context, 16),
                vertical: rs(context, 8),
              ),
              child: TextField(
                controller: controller.reasonController,
                maxLines: 6,
                style: AppTextStyles.bodyMedium(context),
                decoration: InputDecoration(
                  hintText: "e.g., Family emergency, Medical appointment, Personal work...",
                  hintStyle: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.grey,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 MODERN DATE TILE
  Widget _modernDateTile(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color iconColor,
        required Rxn<DateTime> date,
        required VoidCallback onTap,
      }) {
    return Obx(() {
      final isSelected = date.value != null;

      return CustomContainer(
        backgroundColor: isSelected
            ? iconColor.withOpacity(0.08)
            : AppColors.white,
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(
          color: isSelected
              ? iconColor.withOpacity(0.4)
              : AppColors.greyLight,
          width: isSelected ? 2 : 1,
        ),
        onTap: onTap,
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: iconColor.withOpacity(0.15),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ]
            : [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        child: Padding(
          padding: EdgeInsets.all(rs(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ICON
              Container(
                padding: EdgeInsets.all(rs(context, 10)),
                decoration: BoxDecoration(
                  color: isSelected
                      ? iconColor
                      : iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.white : iconColor,
                  size: rs(context, 24),
                ),
              ),

              SizedBox(height: rs(context, 12)),

              /// TITLE
              Text(
                title,
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: rs(context, 2)),

              Text(
                subtitle,
                style: AppTextStyles.caption(context),
              ),

              SizedBox(height: rs(context, 8)),

              /// DATE TIME DISPLAY
              if (date.value == null)
                Text(
                  "Tap to select",
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(date.value!),
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                    SizedBox(height: rs(context, 2)),
                    Text(
                      DateFormat('hh:mm a').format(date.value!),
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: iconColor.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }
}