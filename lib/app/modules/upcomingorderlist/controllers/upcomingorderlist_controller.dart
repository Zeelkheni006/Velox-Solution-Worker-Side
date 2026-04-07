import 'package:get/get.dart';
import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order.dart';
import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order_model.dart';

class UpcomingOrdersListController extends GetxController {
  RxBool isUpcomingOrderLoading = true.obs;
  RxBool isRefreshing = false.obs;
  RxList<OrderModel> upcomingOrders = <OrderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUpcomingOrders();
  }

  Future<void> fetchUpcomingOrders() async {
    try {
      isUpcomingOrderLoading(true);

      final response = await OrderApi.getUpcomingOrders();

      if (response['success'] == true && response['data'] != null) {
        final List list = response['data']['orders'];
        upcomingOrders.value = list.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        upcomingOrders.clear();
      }
    } catch (e) {
      print("UPCOMING ORDER CONTROLLER ERROR ::: $e");
      upcomingOrders.clear();
    } finally {
      isUpcomingOrderLoading(false);
    }
  }

  Future<void> refreshOrders() async {
    try {
      isRefreshing(true);
      final response = await OrderApi.getUpcomingOrders();

      if (response['success'] == true && response['data'] != null) {
        final List list = response['data']['orders'];
        upcomingOrders.value = list.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        upcomingOrders.clear();
      }
    } catch (e) {
      print("UPCOMING ORDER REFRESH ERROR ::: $e");
    } finally {
      isRefreshing(false);
    }
  }
}