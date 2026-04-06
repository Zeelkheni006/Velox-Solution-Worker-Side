import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        if (controller.isUpcomingOrderLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.upcomingOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.access_time_filled,
                    color: AppColors.greyLight, size: 60),
                SizedBox(height: 10),
                Text(
                  'No orders for upcoming',
                  style: TextStyle(color: AppColors.textDisabled),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
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