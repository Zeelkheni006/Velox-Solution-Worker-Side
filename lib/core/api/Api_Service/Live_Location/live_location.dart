import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';

class LiveLocationService {

  static Future<void> sendLiveLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double heading,
    required double speed,
    required int battery,
    required String source,
  }) async {

    try {
      final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.livelocationsend);
      final token = await AppStorage.getWorkerAccessToken();

      final bool isMocked = source.toLowerCase() == "gps" ? false : true;

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
          "accuracy_meters": accuracy,
          "heading": heading,
          "speed_mps": speed,
          "battery_percent": battery,
          "source": source,
          "is_mocked": isMocked,
        }),
      );

      print("LIVE LOCATION RESPONSE: ${response.body}");

    } catch (e) {
      print("LIVE LOCATION ERROR: $e");
    }
  }

  static Future<void> workerStatus({required dynamic isOnline}) async {
    try {
      final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.workerstatus);
      final token = await AppStorage.getWorkerAccessToken();

      final response = await http.patch(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "is_online": isOnline,
        }),
      );

      print("WORKER STATUS : $isOnline");
      print("WORKER STATUS RESPONSE: ${response.body}");
    } catch (e) {
      print("WORKER STATUS ERROR: $e");
    }
  }

}