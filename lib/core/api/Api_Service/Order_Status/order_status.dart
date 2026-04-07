import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';
import '../Worker_Refresh_Token/worker_api_service.dart';

class OrderStatus {

  // ==================== WORKER ORDER STATUS ====================
  static Future<Map<String, dynamic>> workerOrderStatus(int orderId) async {
    try {
      final response = await WorkerApiService.post(
        url: ApiUrl.workerOrderStatus(orderId),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }

  // ==================== ORDER COMPLETE (MULTIPART) ====================
  static Future<Map<String, dynamic>> orderComplete({
    required int orderId,
    required List<File> imageFiles,
  }) async {
    try {
      final token = await AppStorage.getWorkerAccessToken();

      final uri = Uri.parse(ApiUrl.baseUrl + ApiUrl.ordercomplete);
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['order_id'] = orderId.toString();

      for (final file in imageFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('images', file.path),
        );
      }

      final streamed = await request.send();
      final responseData = await streamed.stream.bytesToString();

      return jsonDecode(responseData);
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong.'};
    }
  }
}