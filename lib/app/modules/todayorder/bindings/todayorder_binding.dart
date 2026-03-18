import 'package:get/get.dart';
import '../../../../core/providers/order_provider.dart';
import '../controllers/todayorder_controller.dart';

class TodayOrderBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OrderProvider>()) {
      Get.put<OrderProvider>(OrderProvider(), permanent: true);
    }

    Get.put<TodayOrderController>(
      TodayOrderController(),
    );
  }
}