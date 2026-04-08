import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/Shimmer/order_shimmer_item.dart';
import '../../../../core/constants/app_colors.dart';
import '../../orderdetails/views/order_details_page.dart';
import '../../../../features/orders/presentation/pages/order_list_item.dart';
import '../controllers/todayorder_controller.dart';

class TodayOrderView extends StatelessWidget {
  const TodayOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<TodayOrderController>(
      init: TodayOrderController(),
      builder: (controller) {
        // ── SHIMMER LOADING STATE ──
        if (controller.isTodayOrderLoading.value) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6, // Number of shimmer placeholders
            itemBuilder: (_, __) => const OrderShimmerItem(),
          );
        }

        // ── EMPTY STATE ──
        if (controller.todayOrders.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refreshOrders,
            color: AppColors.primary, // your primary color
            child: ListView(
              // Wrap in ListView so pull-to-refresh works on empty state too
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: AppColors.greyLight,
                        size: 72,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No orders for today',
                        style: TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
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
            itemCount: controller.todayOrders.length,
            itemBuilder: (context, index) {
              final order = controller.todayOrders[index];

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