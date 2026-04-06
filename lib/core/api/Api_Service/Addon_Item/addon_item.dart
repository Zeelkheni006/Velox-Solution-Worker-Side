import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';

class AddonItem {

  static Future<Map<String, dynamic>> addOnItemGet({
    required String search,
    int page = 1,
  }) async {
    try {
      final token = await AppStorage.getWorkerAccessToken();

      final uri = Uri.parse(
        '${ApiUrl.baseUrl}${ApiUrl.addonItemSearch}'
            '?search=$search&page=$page',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }


  static Future<Map<String, dynamic>> addOnAdd({
    required int orderId,
    required List<int> addonItemIds,
    String note = '',
  }) async {
    try {
      final token = await AppStorage.getWorkerAccessToken();

      final uri = Uri.parse('${ApiUrl.baseUrl}${ApiUrl.addonAdd}');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'order_id': orderId,
          'note': note,
          'addon_items': addonItemIds,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addOnRemove({
    required int orderId,
    required int orderAddonItemId,
  }) async {
    try {
      final token = await AppStorage.getWorkerAccessToken();

      final uri = Uri.parse('${ApiUrl.baseUrl}${ApiUrl.addonRemove}');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'order_id': orderId,
          'order_addon_item_id': orderAddonItemId,
        }),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }


  static Future<Map<String, dynamic>> addOnItemShow({
    required int orderId,
  }) async {
    try {
      final token = await AppStorage.getWorkerAccessToken();

      final uri = Uri.parse(
        '${ApiUrl.baseUrl}${ApiUrl.addonItemShow(orderId)}',
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}