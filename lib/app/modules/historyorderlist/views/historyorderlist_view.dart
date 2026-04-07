import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/Shimmer/history_order_shimmer_item.dart';
import '../../../../core/constants/app_colors.dart';
import '../../orderdetails/views/order_details_page.dart';
import '../../../../features/orders/presentation/pages/order_list_item.dart';
import '../controllers/historyorderlist_controller.dart';

class HistoryOrdersListView extends StatelessWidget {
  const HistoryOrdersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<HistoryOrdersListController>(
      init: HistoryOrdersListController(),
      builder: (controller) {
        // ── SHIMMER LOADING STATE ──
        if (controller.isHistoryOrderLoading.value) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            itemBuilder: (_, __) => const HistoryOrderShimmerItem(),
          );
        }

        // ── EMPTY STATE ──
        if (controller.historyOrders.isEmpty) {
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
                        Icons.history_rounded,
                        color: AppColors.greyLight,
                        size: 72,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No order history found',
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

        // ── HISTORY ORDER LIST WITH PULL TO REFRESH ──
        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          color: AppColors.primary,
          strokeWidth: 2.5,
          displacement: 50,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.historyOrders.length,
            itemBuilder: (context, index) {
              final order = controller.historyOrders[index];

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