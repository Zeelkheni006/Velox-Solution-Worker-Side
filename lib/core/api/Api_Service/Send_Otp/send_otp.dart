import 'dart:convert';
import '../../api_endpoints.dart';
import '../Worker_Refresh_Token/worker_api_service.dart';

class SendOtp {

  // ==================== SEND OTP ====================
  static Future<Map<String, dynamic>> verifyUserSendOtp(int orderId) async {
    try {
      final response = await WorkerApiService.post(
        url: ApiUrl.verifysendotp,
        body: {'order_id': orderId},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }

  // ==================== CONFIRM OTP ====================
  static Future<Map<String, dynamic>> verifyConfirmOtp(
      int orderId, String otp) async {
    try {
      final response = await WorkerApiService.post(
        url: ApiUrl.verifyconfirmotp,
        body: {
          'order_id': orderId,
          'otp': otp,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }
}