import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../../../../core/utils/custome_snakbar.dart';
import '../../../../features/profile/presentation/pages/availability_settings_page.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appbar,
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
        title: Text("My Profile", style: AppTextStyles.heading3(context)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            SizedBox(height: rs(context, 12)),
            // _buildStatusCard(context),
            // SizedBox(height: rs(context, 12)),
            // _buildPerformanceCards(context),
            // SizedBox(height: rs(context, 12)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
              child: _buildQuickActions(context),
            ),
            SizedBox(height: rs(context, 12)),
            _buildSettingsSection(context),
            SizedBox(height: rs(context, 16)),
            _buildLogoutSection(context),
            SizedBox(height: rs(context, 24)),
          ],
        ),
      ),
    );
  }

  /// ================= PROFILE HEADER =================
  Widget _buildProfileHeader(BuildContext context) {
    return Obx(() {
      final worker = controller.worker.value;
      return CustomContainer(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: rs(context, 20),
          horizontal: rs(context, 20),
        ),
        backgroundColor: AppColors.appbar,
        borderRadius: BorderRadius.zero,
        child: Column(
          children: [
            // Profile Avatar
            Container(
              padding: EdgeInsets.all(rs(context, 3)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: rs(context, 2.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: rs(context, 12),
                    offset: Offset(0, rs(context, 4)),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.all(rs(context, 2)),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: rs(context, 45),
                  backgroundColor: AppColors.greyLight,
                  backgroundImage: worker["photo"] != null
                      ? NetworkImage(worker["photo"])
                      : null,
                  child: worker["photo"] == null
                      ? Icon(
                    Icons.person,
                    size: rs(context, 45),
                    color: AppColors.primary,
                  )
                      : null,
                ),
              ),
            ),
            SizedBox(height: rs(context, 14)),
            // Name
            Text(
              worker["name"] ?? "",
              style: AppTextStyles.heading3(context).copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: rs(context, 4)),
            Text(
              worker["email"] ?? "",
              style: AppTextStyles.bodySmall(context),
            ),
            SizedBox(height: rs(context, 6)),
            // Phone
            CustomContainer(
              padding: EdgeInsets.symmetric(
                horizontal: rs(context, 14),
                vertical: rs(context, 6),
              ),
              backgroundColor: AppColors.white,
              borderRadius: BorderRadius.circular(rs(context, 20)),
              border: Border.all(
                color: AppColors.border,
                width: rs(context, 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: rs(context, 14),
                    color: AppColors.secondary,
                  ),
                  SizedBox(width: rs(context, 6)),
                  Text(
                    worker["phone"] ?? "",
                    style: AppTextStyles.bodySmall(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// ================= STATUS CARD =================
  Widget _buildStatusCard(BuildContext context) {
    return CustomContainer(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 16)),
      backgroundColor: AppColors.white,
      borderRadius: AppRadii.card(context),
      border: Border.all(
        color: AppColors.border,
        width: rs(context, 1),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withOpacity(0.04),
          blurRadius: rs(context, 10),
          offset: Offset(0, rs(context, 2)),
        ),
      ],
      child: Obx(() {
        final online = controller.isOnline.value;
        return Row(
          children: [
            // Status Indicator
            Container(
              width: rs(context, 50),
              height: rs(context, 50),
              decoration: BoxDecoration(
                color: (online ? AppColors.success : AppColors.error)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: (online ? AppColors.success : AppColors.error)
                      .withOpacity(0.3),
                  width: rs(context, 2),
                ),
              ),
              child: Center(
                child: Container(
                  width: rs(context, 16),
                  height: rs(context, 16),
                  decoration: BoxDecoration(
                    color: online ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            SizedBox(width: rs(context, 16)),
            // Status Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Availability Status',
                    style: AppTextStyles.caption(context).copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: rs(context, 4)),
                  Text(
                    online ? 'ONLINE' : 'OFFLINE',
                    style: AppTextStyles.heading4(context).copyWith(
                      fontSize: rs(context, 18),
                      fontWeight: FontWeight.bold,
                      color: online ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            // Toggle Switch
            Switch(
              value: online,
              onChanged: (value) {
                controller.toggleStatus(value);
                CustomSnackbar.showSuccess(
                  'Status Updated',
                  value ? 'You are now Online!' : 'You are now Offline',
                );
              },
              activeColor: AppColors.success,
              activeTrackColor: AppColors.success.withOpacity(0.5),
              inactiveThumbColor: AppColors.error,
              inactiveTrackColor: AppColors.error.withOpacity(0.5),
            ),
          ],
        );
      }),
    );
  }

  /// ================= PERFORMANCE CARDS =================
  Widget _buildPerformanceCards(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 20)),
      child: Row(
        children: [
          // Rating Card
          Expanded(
            child: _buildMetricCard(
              context: context,
              icon: Icons.star_rounded,
              title: 'Rating',
              value: '4.7',
              color: AppColors.secondary,
            ),
          ),
          SizedBox(width: rs(context, 12)),
          // Jobs Completed Card
          Expanded(
            child: Obx(() => _buildMetricCard(
              context: context,
              icon: Icons.check_circle_rounded,
              title: 'Jobs Done',
              value: controller.completedJobsCount.value.toString(),
              color: AppColors.primary,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return CustomContainer(
      padding: EdgeInsets.all(rs(context, 16)),
      backgroundColor: AppColors.white,
      borderRadius: AppRadii.card(context),
      border: Border.all(
        color: color.withOpacity(0.2),
        width: rs(context, 1.5),
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.08),
          blurRadius: rs(context, 10),
          offset: Offset(0, rs(context, 2)),
        ),
      ],
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(rs(context, 10)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(rs(context, 12)),
            ),
            child: Icon(icon, color: color, size: rs(context, 26)),
          ),
          SizedBox(height: rs(context, 12)),
          Text(
            value,
            style: AppTextStyles.heading3(context).copyWith(
              fontSize: rs(context, 24),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: rs(context, 4)),
          Text(
            title,
            style: AppTextStyles.caption(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= QUICK ACTIONS =================
  Widget _buildQuickActions(BuildContext context) {
    return CustomContainer(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 16)),
      backgroundColor: AppColors.white,
      borderRadius: AppRadii.card(context),
      border: Border.all(
        color: AppColors.border,
        width: rs(context, 1),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withOpacity(0.04),
          blurRadius: rs(context, 10),
          offset: Offset(0, rs(context, 2)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTextStyles.heading4(context).copyWith(
              fontSize: rs(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: rs(context, 12)),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.access_time_rounded,
                  label: 'Leave Request',
                  color: AppColors.primary,
                  onTap: () => Get.toNamed(Routes.WORKERLEAVE),
                ),
              ),
              SizedBox(width: rs(context, 12)),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.edit_rounded,
                  label: 'Edit Profile',
                  color: AppColors.secondary,
                  onTap: () => CustomSnackbar.showInfo('Info', 'Coming Soon'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs(context, 12)),
      child: CustomContainer(
        padding: EdgeInsets.symmetric(vertical: rs(context, 12)),
        backgroundColor: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(rs(context, 12)),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: rs(context, 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: rs(context, 28)),
            SizedBox(height: rs(context, 6)),
            Text(
              label,
              style: AppTextStyles.caption(context).copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ================= SETTINGS SECTION =================
  Widget _buildSettingsSection(BuildContext context) {
    return CustomContainer(
      width: double.infinity,
      backgroundColor: AppColors.white,
      borderRadius: AppRadii.card(context),
      border: Border.all(
        color: AppColors.border,
        width: rs(context, 1),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withOpacity(0.04),
          blurRadius: rs(context, 10),
          offset: Offset(0, rs(context, 2)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              rs(context, 20),
              rs(context, 16),
              rs(context, 20),
              rs(context, 12),
            ),
            child: Text(
              'Settings',
              style: AppTextStyles.heading4(context).copyWith(
                fontSize: rs(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.history_rounded,
            title: 'Leave History',
            subtitle: 'Check Your Leave History',
            onTap: () {
              Get.toNamed(Routes.LEAVEHISTORY);
            },
          ),
          _buildDivider(context),
          _buildSettingsTile(
            context: context,
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              Get.toNamed(Routes.PASSWORDCHANGE);
            },
          ),
          _buildDivider(context),
          _buildSettingsTile(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification settings',
            onTap: () => CustomSnackbar.showInfo('Info', 'Coming Soon'),
          ),
          _buildDivider(context),
          _buildSettingsTile(
            context: context,
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'Get help or contact us',
            onTap: () => CustomSnackbar.showInfo('Info', 'Coming Soon'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: rs(context, 20),
          vertical: rs(context, 12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(rs(context, 8)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(rs(context, 10)),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: rs(context, 20),
              ),
            ),
            SizedBox(width: rs(context, 14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontSize: rs(context, 15),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: rs(context, 2)),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption(context),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: rs(context, 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 20)),
      child: Divider(
        height: rs(context, 1),
        thickness: rs(context, 1),
        color: AppColors.border,
      ),
    );
  }

  /// ================= LOGOUT SECTION =================
  Widget _buildLogoutSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: rs(context, 20)),
      child: InkWell(
        onTap: () {
          Get.defaultDialog(
            title: 'Logout',
            titleStyle: AppTextStyles.heading3(context).copyWith(
              fontSize: rs(context, 20),
              fontWeight: FontWeight.bold,
            ),
            middleText: 'Are you sure you want to logout?',
            middleTextStyle: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.textSecondary,
            ),
            radius: rs(context, 16),
            backgroundColor: AppColors.white,
            confirm: ElevatedButton(
              onPressed: controller.logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: rs(context, 32),
                  vertical: rs(context, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rs(context, 12)),
                ),
                elevation: 0,
              ),
              child: Text(
                'Logout',
                style: AppTextStyles.buttonMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            cancel: TextButton(
              onPressed: Get.back,
              child: Text(
                'Cancel',
                style: AppTextStyles.buttonMedium(context).copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(rs(context, 12)),
        child: CustomContainer(
          padding: EdgeInsets.symmetric(vertical: rs(context, 14)),
          backgroundColor: AppColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(rs(context, 12)),
          border: Border.all(
            color: AppColors.error.withOpacity(0.3),
            width: rs(context, 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: rs(context, 20),
              ),
              SizedBox(width: rs(context, 12)),
              Text(
                'Logout',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.error,
                  fontSize: rs(context, 15),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}