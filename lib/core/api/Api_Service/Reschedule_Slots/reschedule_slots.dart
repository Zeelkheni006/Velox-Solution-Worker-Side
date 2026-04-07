import 'dart:convert';
import '../../api_endpoints.dart';
import '../Worker_Refresh_Token/worker_api_service.dart';

class RescheduleSlots {

  // ==================== GET AVAILABLE SLOTS ====================
  static Future<Map<String, dynamic>> rescheduleslot(int orderId) async {
    try {
      final response = await WorkerApiService.get(
        url: ApiUrl.rescheduleAvailableSlots,
        queryParams: {'order_id': orderId.toString()},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== CONFIRM SLOT ====================
  static Future<Map<String, dynamic>> confirmslot({
    required int orderId,
    required String serviceDate,
    required String slotStartTime,
    String note = '',
  }) async {
    try {
      final response = await WorkerApiService.post(
        url: ApiUrl.slotconfirm,
        body: {
          'order_id': orderId,
          'service_date': serviceDate,
          'slot_start_time': slotStartTime,
          'note': note,
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}