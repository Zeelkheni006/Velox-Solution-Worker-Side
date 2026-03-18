import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
    required File imageFile,
  }) async {
    final token = await AppStorage.getWorkerAccessToken();

    final uri = Uri.parse(
      ApiUrl.baseUrl + ApiUrl.ordercomplete,
    );

    var request = http.MultipartRequest("POST", uri);

    request.headers['Authorization'] = "Bearer $token";

    request.fields['order_id'] = orderId.toString();

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ),
    );

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    print("COMPLETE ORDER RESPONSE ::: $responseData");

    return jsonDecode(responseData);
  }
}