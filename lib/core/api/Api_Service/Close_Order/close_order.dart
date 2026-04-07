import 'dart:convert';
import '../../api_endpoints.dart';
import '../Worker_Refresh_Token/worker_api_service.dart';

class CloseOrder {
  static Future<Map<String, dynamic>> closeOrder(int orderId) async {
    try {
      final response = await WorkerApiService.post(
        url: ApiUrl.closeorder,
        body: {'order_id': orderId},
      );

      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic>
          ? decoded
          : {'success': false, 'message': 'Invalid response'};
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }
}