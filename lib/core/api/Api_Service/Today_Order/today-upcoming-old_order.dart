import 'dart:convert';
import '../../api_endpoints.dart';
import '../Worker_Refresh_Token/worker_api_service.dart';

class OrderApi {

  static Future<Map<String, dynamic>> getTodayOrders() async {
    try {
      final response = await WorkerApiService.get(url: ApiUrl.todayorders);
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "data": null};
    }
  }

  static Future<Map<String, dynamic>> getUpcomingOrders() async {
    try {
      final response = await WorkerApiService.get(url: ApiUrl.upcomingorders);
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "data": null};
    }
  }

  static Future<Map<String, dynamic>> getHistoryOrders() async {
    try {
      final response = await WorkerApiService.get(url: ApiUrl.historyorders);
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "data": null};
    }
  }

  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final response = await WorkerApiService.get(
        url: ApiUrl.orderDetails(orderId),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "data": null};
    }
  }
}