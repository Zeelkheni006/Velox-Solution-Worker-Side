import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';

class OrderStatus {

  static Future<Map<String, dynamic>> workerOrderStatus(int orderId) async {
    final token = await AppStorage.getWorkerAccessToken();

    final uri = Uri.parse(
      ApiUrl.baseUrl + ApiUrl.workerOrderStatus(orderId),
    );

    final response = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> orderComplete({
    required int orderId,
    required List<File> imageFiles, // ✅ CHANGED: single → list of 5
  }) async {
    final token = await AppStorage.getWorkerAccessToken();

    final uri = Uri.parse(
      ApiUrl.baseUrl + ApiUrl.ordercomplete,
    );

    var request = http.MultipartRequest("POST", uri);

    request.headers['Authorization'] = "Bearer $token";
    request.fields['order_id'] = orderId.toString();

    for (final file in imageFiles) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          file.path,
        ),
      );
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    print("COMPLETE ORDER RESPONSE ::: $responseData");

    return jsonDecode(responseData);
  }
}