import 'package:apilearning/core/api/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/Shimmer/profile_shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/theme_controller.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../../../../core/utils/custome_snakbar.dart';
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
      body: Obx(() {
        // ── SHIMMER LOADING STATE ──
        if (controller.isLoading.value) {
          return const ProfileShimmer();
        }

        // ── MAIN CONTENT WITH PULL TO REFRESH ──
        return RefreshIndicator(
          onRefresh: controller.refreshProfile,
          color: AppColors.primary,
          strokeWidth: 2.5,
          displacement: 50,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildProfileHeader(context),
                SizedBox(height: rs(context, 12)),
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: rs(context, 16)),
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
      }),
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
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: rs(context, 45),
                  backgroundColor: AppColors.greyLight,
                  backgroundImage: worker["photo"] != null
                      ? NetworkImage("${ApiUrl.baseUrl}${worker["photo"]}")
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
            // Phone badge
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

  /// ================= QUICK ACTIONS =================
  Widget _buildQuickActions(BuildContext context) {
    return CustomContainer(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 16)),
      backgroundColor: AppColors.white,
      borderRadius: AppRadii.card(context),
      border: Border.all(color: AppColors.border, width: rs(context, 1)),
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
                child: Obx(() {
                  final rating = (controller.worker["rating"] ?? 0.0).toDouble();

                  return CustomContainer(
                    padding: EdgeInsets.symmetric(vertical: rs(context, 18)),
                    backgroundColor: Colors.amber.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(rs(context, 12)),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: rs(context, 1),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: rs(context, 28),
                          ),
                          SizedBox(width: rs(context, 18)),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                rating.toStringAsFixed(2),
                                style: AppTextStyles.bodyMedium(context).copyWith(
                                  color: Colors.amber[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: rs(context, 0)),
                              Text(
                                "Rating",
                                style: AppTextStyles.caption(context).copyWith(
                                  color: AppColors.primary.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
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
      border: Border.all(color: AppColors.border, width: rs(context, 1)),
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
          _buildThemeSelector(context),
          _buildDivider(context),
          _buildSettingsTile(
            context: context,
            icon: Icons.history_rounded,
            title: 'Leave History',
            subtitle: 'Check Your Leave History',
            onTap: () => Get.toNamed(Routes.LEAVEHISTORY),
          ),
          // _buildDivider(context),
          // _buildSettingsTile(
          //   context: context,
          //   icon: Icons.lock_outline_rounded,
          //   title: 'Change Password',
          //   subtitle: 'Update your password',
          //   onTap: () => Get.toNamed(Routes.PASSWORDCHANGE),
          // ),
          _buildDivider(context),
          _buildSettingsTile(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              Get.toNamed(Routes.PRIVACYPOLICY);
            },
          ),
          // _buildDivider(context),
          // _buildSettingsTile(
          //   context: context,
          //   icon: Icons.help_outline_rounded,
          //   title: 'Help & Support',
          //   subtitle: 'Get help or contact us',
          //   onTap: () => CustomSnackbar.showInfo('Info', 'Coming Soon'),
          // ),
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
                  Text(subtitle, style: AppTextStyles.caption(context)),
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

  Widget _buildThemeSelector(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    final options = [
      {'key': 'light',  'icon': Icons.light_mode_outlined,    'label': 'Light'},
      {'key': 'system', 'icon': Icons.brightness_auto_outlined,'label': 'System'},
      {'key': 'dark',   'icon': Icons.dark_mode_outlined,     'label': 'Dark'},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rs(context, 20),
        vertical: rs(context, 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(rs(context, 8)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(rs(context, 10)),
                ),
                child: Icon(
                  Icons.brightness_6_outlined,
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
                      'Appearance',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontSize: rs(context, 15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: rs(context, 2)),
                    Text(
                      'Choose your theme',
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: rs(context, 12)),
          Obx(() {
            final current = themeCtrl.themeMode.value;
            return Row(
              children: options.map((opt) {
                final key    = opt['key'] as String;
                final icon   = opt['icon'] as IconData;
                final label  = opt['label'] as String;
                final active = current == key;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => themeCtrl.setTheme(key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: key != 'dark' ? rs(context, 8) : 0,
                      ),
                      padding: EdgeInsets.symmetric(vertical: rs(context, 10)),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(rs(context, 10)),
                        border: Border.all(
                          color: active
                              ? AppColors.primary
                              : AppColors.border,
                          width: active ? rs(context, 1.5) : rs(context, 1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: rs(context, 20),
                            color: active
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          SizedBox(height: rs(context, 4)),
                          Text(
                            label,
                            style: AppTextStyles.caption(context).copyWith(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}