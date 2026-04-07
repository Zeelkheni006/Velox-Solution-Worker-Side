import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../utils/app_storage.dart';
import '../../api_endpoints.dart';
import 'worker_refresh_token.dart';

class WorkerApiService {

  // ==================== HEADERS ====================
  static Future<Map<String, String>> _headers() async {
    final token = await AppStorage.getWorkerAccessToken();
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  // ==================== RETRY HELPER ====================
  static Future<http.Response> _withRefreshRetry(
      Future<http.Response> Function(Map<String, String> headers) call,
      ) async {
    var headers = await _headers();
    var response = await call(headers);

    if (response.statusCode == 401) {
      final refreshed = await WorkerRefreshToken.handleRefreshToken();

      if (refreshed) {
        headers = await _headers(); // fetch updated token
        response = await call(headers);
      }
      // if not refreshed, _forceLogout() already ran inside handleRefreshToken
    }

    return response;
  }

  // ==================== GET ====================
  static Future<http.Response> get({
    required String url,
    Map<String, String>? queryParams,
  }) async {
    return _withRefreshRetry((headers) {
      Uri uri = Uri.parse(ApiUrl.baseUrl + url);
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      return http.get(uri, headers: headers);
    });
  }

  // ==================== POST ====================
  static Future<http.Response> post({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _withRefreshRetry((headers) {
      return http.post(
        Uri.parse(ApiUrl.baseUrl + url),
        headers: headers,
        body: jsonEncode(body ?? {}),
      );
    });
  }

  // ==================== PUT ====================
  static Future<http.Response> put({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _withRefreshRetry((headers) {
      return http.put(
        Uri.parse(ApiUrl.baseUrl + url),
        headers: headers,
        body: jsonEncode(body ?? {}),
      );
    });
  }

  // ==================== PATCH ====================
  static Future<http.Response> patch({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _withRefreshRetry((headers) {
      return http.patch(
        Uri.parse(ApiUrl.baseUrl + url),
        headers: headers,
        body: jsonEncode(body ?? {}),
      );
    });
  }

  // ==================== DELETE ====================
  static Future<http.Response> delete({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    return _withRefreshRetry((headers) {
      return http.delete(
        Uri.parse(ApiUrl.baseUrl + url),
        headers: headers,
        body: jsonEncode(body ?? {}),
      );
    });
  }
}