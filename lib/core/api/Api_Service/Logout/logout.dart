import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../api_endpoints.dart';

class LogoutApi {
  static Future<Map<String, dynamic>> logout({
    required String token,
    required String xDeviceID,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.logout),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Device-Id': xDeviceID,
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Server error"};
    }
  }
}
