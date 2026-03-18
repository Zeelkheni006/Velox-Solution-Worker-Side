import 'package:get/get.dart';
import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order.dart';
import '../../../../core/api/Api_Service/Today_Order/today-upcoming-old_order_model.dart';

class TodayOrderController extends GetxController {
  RxBool isTodayOrderLoading = true.obs;
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

      print("TODAY ORDER BODY ::: ${response}");

      if (response['success'] == true && response['data'] != null) {
        final List list = response['data']['orders'];

        todayOrders.value =
            list.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        todayOrders.clear();
      }
    } catch (e) {
      print("TODAY ORDER CONTROLLER ERROR ::: $e");
      todayOrders.clear();
    } finally {
      isTodayOrderLoading(false);
    }
  }

  Future<void> refreshOrders() async {
    await fetchTodayOrders();
  }
}
