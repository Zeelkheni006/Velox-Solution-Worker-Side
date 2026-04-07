import 'dart:convert';
import '../../api_endpoints.dart';
import '../Worker_Refresh_Token/worker_api_service.dart';

class AddonItem {

  // ==================== GET ADDON ITEMS (SEARCH) ====================
  static Future<Map<String, dynamic>> addOnItemGet({
    required String search,
    int page = 1,
  }) async {
    try {
      final response = await WorkerApiService.get(
        url: ApiUrl.addonItemSearch,
        queryParams: {
          'search': search,
          'page': page.toString(),
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== ADD ADDON ====================
  static Future<Map<String, dynamic>> addOnAdd({
    required int orderId,
    required List<int> addonItemIds,
    String note = '',
  }) async {
    try {
      final response = await WorkerApiService.post(
        url: ApiUrl.addonAdd,
        body: {
          'order_id': orderId,
          'note': note,
          'addon_items': addonItemIds,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== REMOVE ADDON ====================
  static Future<Map<String, dynamic>> addOnRemove({
    required int orderId,
    required int orderAddonItemId,
  }) async {
    try {
      final response = await WorkerApiService.post(
        url: ApiUrl.addonRemove,
        body: {
          'order_id': orderId,
          'order_addon_item_id': orderAddonItemId,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================== SHOW ADDON ITEMS ====================
  static Future<Map<String, dynamic>> addOnItemShow({
    required int orderId,
  }) async {
    try {
      final response = await WorkerApiService.get(
        url: ApiUrl.addonItemShow(orderId),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}