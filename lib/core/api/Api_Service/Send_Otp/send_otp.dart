import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';

class SendOtp {

  static Future<Map<String, dynamic>> verifyUserSendOtp(int orderId) async {
    final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.verifysendotp);
    final token = await AppStorage.getWorkerAccessToken();

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "order_id": orderId,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyConfirmOtp(
      int orderId, String otp) async {
    final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.verifyconfirmotp);
    final token = await AppStorage.getWorkerAccessToken();

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "order_id": orderId,
        "otp": otp,
      }),
    );

    return jsonDecode(response.body);
  }
}
