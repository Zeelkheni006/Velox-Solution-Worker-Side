import 'package:get/get.dart';
import '../../../../core/App_Safety/app_safety.dart';
import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order.dart';
import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order_model.dart';

class TodayOrderController extends GetxController {
  RxBool isTodayOrderLoading = true.obs;
  RxBool isRefreshing = false.obs;
  RxList<OrderModel> todayOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodayOrders();
  }

  Future<void> fetchTodayOrders() async {
    try {
      isTodayOrderLoading(true);

      final response = await OrderApi.getTodayOrders();

      if (response['success'] == true && response['data'] != null) {
        final List list = response['data']['orders'];
        todayOrders.value = list.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        todayOrders.clear();
      }
    } catch (e) {
      logPrint("TODAY ORDER CONTROLLER ERROR ::: $e");
      todayOrders.clear();
    } finally {
      isTodayOrderLoading(false);
    }
  }

  Future<void> refreshOrders() async {
    try {
      isRefreshing(true);
      final response = await OrderApi.getTodayOrders();

      if (response['success'] == true && response['data'] != null) {
        final List list = response['data']['orders'];
        todayOrders.value = list.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        todayOrders.clear();
      }
    } catch (e) {
      logPrint("TODAY ORDER REFRESH ERROR ::: $e");
    } finally {
      isRefreshing(false);
    }
  }
}