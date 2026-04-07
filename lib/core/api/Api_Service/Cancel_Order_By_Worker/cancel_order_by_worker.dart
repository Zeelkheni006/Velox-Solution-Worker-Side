import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';

class CancelOrderByWorker {

  static Future<Map<String, dynamic>> orderCancelByWorker({
    required int orderId,
    required String note,
    required double visitingFee,
  }) async {
    try {
      final token = await AppStorage.getWorkerAccessToken();

      final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.ordercancelbyworker);

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'order_id': orderId,
          'note': note,
          'visiting_fee': visitingFee,
        }),
      );

      print("CANCEL ORDER STATUS ::: ${response.statusCode}");
      print("CANCEL ORDER BODY   ::: ${response.body}");

      final decoded = jsonDecode(response.body);
      return decoded as Map<String, dynamic>;
    } catch (e) {
      print("CANCEL ORDER BY WORKER ERROR ::: $e");
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.',
      };
    }
  }

}