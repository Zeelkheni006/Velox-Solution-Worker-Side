import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../App_Safety/app_safety.dart';
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';
import '../Worker_Refresh_Token/worker_api_service.dart';

class ProfileApi {

  // ==================== GET PROFILE DATA ====================
  static Future<Map<String, dynamic>> getProfileData() async {
    try {
      final response = await WorkerApiService.get(
        url: ApiUrl.getuserprofiledata,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        return {
          "success": true,
          "data": data["data"][0],
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed",
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final url = Uri.parse(ApiUrl.baseUrl + ApiUrl.changepassword);

    final body = {
      "old_password": oldPassword,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    };

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    // 🔹 PRINT RESPONSE DATA
    logPrint("Status Code: ${response.statusCode}");
    logPrint("Raw Response Body:");
    logPrint(response.body);

    final decodedResponse = jsonDecode(response.body);
    return decodedResponse;
  }
}
