import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';

class OrderApi {

  static Future<Map<String, dynamic>> getTodayOrders() async {
    try {
      final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.todayorders);
      final token = await AppStorage.getWorkerAccessToken();

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print("TODAY ORDER API ERROR ::: $e");
      return {"success": false, "data": null};
    }
  }

  static Future<Map<String, dynamic>> getUpcomingOrders() async {
    try {
      final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.upcomingorders);
      final token = await AppStorage.getWorkerAccessToken();

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print("UPCOMING ORDER API ERROR ::: $e");
      return {"success": false, "data": null};
    }
  }

  static Future<Map<String, dynamic>> getHistoryOrders() async {
    try {
      final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.historyorders);
      final token = await AppStorage.getWorkerAccessToken();

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print("HISTORY ORDER API ERROR ::: $e");
      return {"success": false, "data": null};
    }
  }

  static Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    try {
      final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.orderDetails(orderId));
      final token = await AppStorage.getWorkerAccessToken();

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("ORDER DETAILS STATUS ::: ${response.statusCode}");
      print("ORDER DETAILS BODY ::: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("ORDER DETAILS API ERROR ::: $e");
      return {"success": false, "data": null};
    }
  }
}
