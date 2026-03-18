import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api_endpoints.dart';

class ApiAuth {

  static Future<Map<String, dynamic>> loginInitiate({
    required String endpoint,
    required String xDeviceID,
    required String xDeviceType,
    required String xDeviceName,
    required String xDeviceOsVersion,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + endpoint),
        headers: {
          'Content-Type': 'application/json',
          'X-Device-Id': xDeviceID,
          'X-Device-Type': xDeviceType,
          'X-Device-Name': xDeviceName,
          'X-Os-Version': xDeviceOsVersion,
        },
        body: jsonEncode(body),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Server error"};
    }
  }

  static Future<Map<String, dynamic>> loginWithPassword({
    required String endpoint,
    required String xDeviceID,
    required String xDeviceType,
    required String xDeviceName,
    required String xDeviceOsVersion,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + endpoint),
        headers: {
          'Content-Type': 'application/json',
          'X-Device-Id': xDeviceID,
          'X-Device-Type': xDeviceType,
          'X-Device-Name': xDeviceName,
          'X-Os-Version': xDeviceOsVersion,
        },
        body: jsonEncode(body),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Server error"};
    }
  }

  static Future<Map<String, dynamic>> loginThroughOtpVerify({
    required String endpoint,
    required String xDeviceID,
    required String xDeviceType,
    required String xDeviceName,
    required String xDeviceOsVersion,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + endpoint),
        headers: {
          'Content-Type': 'application/json',
          'X-Device-Id': xDeviceID,
          'X-Device-Type': xDeviceType,
          'X-Device-Name': xDeviceName,
          'X-Os-Version': xDeviceOsVersion,
        },
        body: jsonEncode(body),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Server error"};
    }
  }
}
