import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../../../routes/app_pages.dart';
import '../../historyorderlist/views/historyorderlist_view.dart';
import '../../todayorder/views/todayorder_view.dart';
import '../../upcomingorderlist/views/upcomingorderlist_view.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with SingleTickerProviderStateMixin {

  late TabController tabController;
  final controller = Get.find<DashboardController>();

  @override
  void initState() {
    super.initState();
    tabController =
        TabController(length: controller.tabs.length, vsync: this);

    tabController.addListener(() {
      controller.selectedIndex.value = tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabViews = [
      TodayOrderView(),
      UpcomingOrdersListView(),
      HistoryOrdersListView(),
    ];

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.appbar,
          elevation: 0,
          title: Text(
            'Velox Solution',
            style: AppTextStyles.heading4(context).copyWith(
              color: AppColors.primary,
            ),
          ),
          actions: [
            // Online/Offline Status Badge
            // Padding(
            //   padding: EdgeInsets.only(right: rs(context, 8)),
            //   child: Center(
            //     child: CustomContainer(
            //       padding: EdgeInsets.symmetric(
            //         horizontal: rs(context, 12),
            //         vertical: rs(context, 6),
            //       ),
            //       backgroundColor: controller.isOnline.value
            //           ? AppColors.success.withOpacity(0.15)
            //           : AppColors.error.withOpacity(0.15),
            //       borderRadius: BorderRadius.all(AppRadii.sm(context)),
            //       border: Border.all(
            //         color: controller.isOnline.value
            //             ? AppColors.success
            //             : AppColors.error,
            //         width: 1.5,
            //       ),
            //       child: Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           CustomContainer(
            //             width: rs(context, 8),
            //             height: rs(context, 8),
            //             backgroundColor: controller.isOnline.value
            //                 ? AppColors.success
            //                 : AppColors.error,
            //             borderRadius: BorderRadius.circular(100),
            //           ),
            //           SizedBox(width: rs(context, 6)),
            //           Text(
            //             controller.isOnline.value ? 'ONLINE' : 'OFFLINE',
            //             style: AppTextStyles.caption(context).copyWith(
            //               color: controller.isOnline.value
            //                   ? AppColors.success
            //                   : AppColors.error,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            // Profile Icon Button
            CustomContainer(
              width: rs(context, 44),
              height: rs(context, 44),
              backgroundColor: Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                Get.toNamed(Routes.PROFILE);
              },
              child: Icon(
                Icons.account_circle,
                size: rs(context, 28),
                color: AppColors.primary,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(rs(context, 60)),
            child: CustomContainer(
              backgroundColor: AppColors.appbar,
              borderRadius: BorderRadius.zero,
              child: TabBar(
                controller: controller.tabController,
                tabs: controller.tabs,
                labelColor: AppColors.secondary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTextStyles.bodyMedium(context),
                indicatorColor: AppColors.secondary,
                indicatorWeight: rs(context, 3),
                indicatorSize: TabBarIndicatorSize.tab,
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: controller.tabController,
          children: tabViews,
        ),

        // Floating Action Button - Only when OFFLINE
        // floatingActionButton: Obx(() {
        //   return !controller.isOnline.value
        //       ? FloatingActionButton.extended(
        //     onPressed: controller.goOnline,
        //     label: Text(
        //       'Go Online',
        //       style: AppTextStyles.buttonMedium(context),
        //     ),
        //     icon: Icon(Icons.electric_bolt, size: rs(context, 20)),
        //     backgroundColor: AppColors.success,
        //     elevation: rs(context, 4),
        //   )
        //       : const SizedBox();
        // }),
      );
  }
}