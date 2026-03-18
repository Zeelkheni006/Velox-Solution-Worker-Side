import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';

class WorkerLeaveApi {

  static Future<Map<String, dynamic>> requestLeave({
    required String startDatetime,
    required String endDatetime,
    required String reason,
  }) async {
    final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.workerleaverequest);
    final token = await AppStorage.getWorkerAccessToken();

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "start_datetime": startDatetime,
        "end_datetime": endDatetime,
        "reason": reason,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> workerLeaveCheck() async {
    final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.workerleavecheck);
    final token = await AppStorage.getWorkerAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> workerLeaveRequestStatus(int requestId) async {
    final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.workerLeaveRequestStatus(requestId));

    final token = await AppStorage.getWorkerAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> requestLeaveHistory() async {
    final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.workerleavehistory);
    final token = await AppStorage.getWorkerAccessToken();

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final decoded = jsonDecode(response.body);

    if (decoded['success'] == true) {
      return decoded['message'];
    } else {
      throw Exception("Failed to load leave history");
    }
  }

}