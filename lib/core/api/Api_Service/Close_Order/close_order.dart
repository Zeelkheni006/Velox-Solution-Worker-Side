import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';

class CloseOrder {
  static Future<Map<String, dynamic>> closeOrder(int orderId) async {
    try {
      final token = await AppStorage.getWorkerAccessToken();

      final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.closeorder);

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'order_id': orderId}),
      );

      print("CLOSE ORDER STATUS CODE ::: ${response.statusCode}");
      print("CLOSE ORDER BODY ::: ${response.body}");

      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic>
          ? decoded
          : {'success': false, 'message': 'Invalid response'};
    } catch (e) {
      print("CLOSE ORDER API ERROR ::: $e");
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }
}