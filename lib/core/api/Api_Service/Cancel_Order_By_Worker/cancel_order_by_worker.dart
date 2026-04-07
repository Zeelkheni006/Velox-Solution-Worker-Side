import 'dart:convert';
import '../../api_endpoints.dart';
import '../Worker_Refresh_Token/worker_api_service.dart';

class CancelOrderByWorker {

  static Future<Map<String, dynamic>> orderCancelByWorker({
    required int orderId,
    required String note,
    required double visitingFee,
  }) async {
    try {
      final response = await WorkerApiService.post(
        url: ApiUrl.ordercancelbyworker,
        body: {
          'order_id': orderId,
          'note': note,
          'visiting_fee': visitingFee,
        },
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }
}