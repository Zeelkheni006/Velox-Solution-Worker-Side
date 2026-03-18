import 'package:get/get.dart';
import '../../../../core/providers/order_provider.dart';
import '../controllers/historyorderlist_controller.dart';

class HistoryOrdersListBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OrderProvider>()) {
      Get.put<OrderProvider>(OrderProvider(), permanent: true);
    }

    Get.put<HistoryOrdersListController>(
      HistoryOrdersListController(),
    );
  }
}
