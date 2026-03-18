import 'package:get/get.dart';
import '../../../../core/providers/order_provider.dart';
import '../controllers/upcomingorderlist_controller.dart';

class UpcomingOrdersListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OrderProvider>()) {
      Get.put<OrderProvider>(OrderProvider(), permanent: true);
    }

    Get.put<UpcomingOrdersListController>(
      UpcomingOrdersListController(),
    );
  }
}