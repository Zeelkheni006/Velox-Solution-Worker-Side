import 'dart:convert';
import '../../api_endpoints.dart';
import '../Worker_Refresh_Token/worker_api_service.dart';

class WorkerLeaveApi {

  // ==================== REQUEST LEAVE ====================
  static Future<Map<String, dynamic>> requestLeave({
    required String startDatetime,
    required String endDatetime,
    required String reason,
  }) async {
    try {
      final response = await WorkerApiService.post(
        url: ApiUrl.workerleaverequest,
        body: {
          'start_datetime': startDatetime,
          'end_datetime': endDatetime,
          'reason': reason,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }

  // ==================== LEAVE CHECK ====================
  static Future<Map<String, dynamic>> workerLeaveCheck() async {
    try {
      final response = await WorkerApiService.get(
        url: ApiUrl.workerleavecheck,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }

  // ==================== LEAVE REQUEST STATUS ====================
  static Future<Map<String, dynamic>> workerLeaveRequestStatus(
      int requestId) async {
    try {
      final response = await WorkerApiService.get(
        url: ApiUrl.workerLeaveRequestStatus(requestId),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }

  // ==================== LEAVE HISTORY ====================
  static Future<Map<String, dynamic>> requestLeaveHistory() async {
    try {
      final response = await WorkerApiService.get(
        url: ApiUrl.workerleavehistory,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }
}