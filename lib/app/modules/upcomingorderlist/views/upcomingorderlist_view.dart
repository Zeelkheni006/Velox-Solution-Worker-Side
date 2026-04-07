import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/Shimmer/upcoming_order_shimmer_item.dart';
import '../../../../core/constants/app_colors.dart';
import '../../orderdetails/views/order_details_page.dart';
import '../../../../features/orders/presentation/pages/order_list_item.dart';
import '../controllers/upcomingorderlist_controller.dart';

class UpcomingOrdersListView extends StatelessWidget {
  const UpcomingOrdersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<UpcomingOrdersListController>(
      init: UpcomingOrdersListController(),
      builder: (controller) {
        // ── SHIMMER LOADING STATE ──
        if (controller.isUpcomingOrderLoading.value) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            itemBuilder: (_, __) => const UpcomingOrderShimmerItem(),
          );
        }

        // ── EMPTY STATE ──
        if (controller.upcomingOrders.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refreshOrders,
            color: AppColors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.access_time_filled,
                        color: AppColors.greyLight,
                        size: 72,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No upcoming orders',
                        style: TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          color: AppColors.greyLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // ── ORDER LIST WITH PULL TO REFRESH ──
        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          color: AppColors.primary,
          strokeWidth: 2.5,
          displacement: 50,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.upcomingOrders.length,
            itemBuilder: (context, index) {
              final order = controller.upcomingOrders[index];

              return OrderListItem(
                order: order,
                onTap: () {
                  Get.to(() => OrderDetailsPage(orderId: order.orderId))
                      ?.then((_) {
                    controller.refreshOrders();
                  });
                },
              );
            },
          ),
        );
      },
    );
  }
}