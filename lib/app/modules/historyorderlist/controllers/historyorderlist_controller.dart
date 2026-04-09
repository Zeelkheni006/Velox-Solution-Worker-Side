import 'package:get/get.dart';
import '../../../../core/App_Safety/app_safety.dart';
import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order.dart';
import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order_model.dart';

class HistoryOrdersListController extends GetxController {
  RxBool isHistoryOrderLoading = true.obs;
  RxBool isRefreshing = false.obs;
  RxList<OrderModel> historyOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistoryOrders();
  }

  Future<void> fetchHistoryOrders() async {
    try {
      isHistoryOrderLoading(true);

      final response = await OrderApi.getHistoryOrders();

      if (response['success'] == true && response['data'] != null) {
        final List list = response['data']['orders'];
        historyOrders.value = list.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        historyOrders.clear();
      }
    } catch (e) {
      logPrint("HISTORY ORDER CONTROLLER ERROR ::: $e");
      historyOrders.clear();
    } finally {
      isHistoryOrderLoading(false);
    }
  }

  Future<void> refreshOrders() async {
    try {
      isRefreshing(true);
      final response = await OrderApi.getHistoryOrders();

      if (response['success'] == true && response['data'] != null) {
        final List list = response['data']['orders'];
        historyOrders.value = list.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        historyOrders.clear();
      }
    } catch (e) {
      logPrint("HISTORY ORDER REFRESH ERROR ::: $e");
    } finally {
      isRefreshing(false);
    }
  }
}