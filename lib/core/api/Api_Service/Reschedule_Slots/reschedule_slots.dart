import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';

class RescheduleSlots {
  /// GET available slots for rescheduling
  /// Endpoint: GET /api/v1/worker/dashboard/orders/reschedule/available-slots?order_id=XXX
  static Future<Map<String, dynamic>> rescheduleslot(int orderId) async {
    try {
      final token = await AppStorage.getWorkerAccessToken();

      final uri = Uri.parse(
          '${ApiUrl.baseUrl}/api/v1/worker/dashboard/orders/reschedule/available-slots'
      ).replace(queryParameters: {'order_id': orderId.toString()});

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      print('RESCHEDULE SLOTS RESPONSE ::: $data');
      return data;
    } catch (e) {
      print('RESCHEDULE SLOTS ERROR ::: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// POST confirm reschedule
  /// Endpoint: POST /api/v1/worker/dashboard/orders/reschedule/confirm
  /// Body: { order_id, service_date, slot_start_time, note }
  static Future<Map<String, dynamic>> confirmslot({
    required int orderId,
    required String serviceDate,       // "2026-04-06"
    required String slotStartTime,     // "11:30:00"
    String note = '',
  }) async {
    try {
      final token = await AppStorage.getWorkerAccessToken();

      final uri = Uri.parse('${ApiUrl.baseUrl}${ApiUrl.slotconfirm}');

      final body = jsonEncode({
        'order_id': orderId,
        'service_date': serviceDate,
        'slot_start_time': slotStartTime,
        'note': note,
      });

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      final data = jsonDecode(response.body);
      print('CONFIRM SLOT RESPONSE ::: $data');
      return data;
    } catch (e) {
      print('CONFIRM SLOT ERROR ::: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}