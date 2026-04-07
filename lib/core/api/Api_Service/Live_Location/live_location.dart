import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';
import '../Worker_Refresh_Token/worker_api_service.dart';

class LiveLocationService {

  // ==================== SEND LIVE LOCATION ====================
  static Future<Map<String, dynamic>> sendLiveLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double heading,
    required double speed,
    required int battery,
    required String source,
  }) async {
    final body = {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy_meters': accuracy,
      'heading': heading,
      'speed_mps': speed,
      'battery_percent': battery,
      'source': source,
      'is_mocked': source.toLowerCase() != 'gps',
    };

    try {
      final isLoggedIn = await AppStorage.isWorkerLoggedIn();

      if (isLoggedIn) {

        final response = await WorkerApiService.post(
          url: ApiUrl.livelocationsend,
          body: body,
        );

        print("LOGIN LIVE LOCATION RESPONSE ::: ${response.body}");

        return jsonDecode(response.body);
      } else {

        final response = await http.post(
          Uri.parse(ApiUrl.baseUrl + ApiUrl.livelocationsend),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        print("NOT LOGIN LIVE LOCATION RESPONSE ::: ${response.body}");
        return jsonDecode(response.body);
      }
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }

  // ==================== WORKER STATUS ====================
  static Future<Map<String, dynamic>> workerStatus({
    required bool isOnline,
  }) async {
    try {
      final response = await WorkerApiService.patch(
        url: ApiUrl.workerstatus,
        body: {'is_online': isOnline},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }
}