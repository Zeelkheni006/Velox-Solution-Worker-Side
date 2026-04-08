import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../app/routes/app_pages.dart';
import '../../../utils/app_storage.dart';
import '../../../utils/custome_snakbar.dart';
import '../../../utils/device_info_service.dart';
import '../../../utils/full_screen_loader.dart';
import '../../api_endpoints.dart';
import '../Logout/logout.dart';

class WorkerRefreshToken {

  // ==================== LOCK (Race Condition Fix) ====================
  static bool _isRefreshing = false;
  static Future<bool>? _refreshFuture;

  static Future<bool> handleRefreshToken() async {

    if (_isRefreshing && _refreshFuture != null) {

      return _refreshFuture!;
    }

    _isRefreshing = true;
    _refreshFuture = _doRefresh();

    final result = await _refreshFuture!;

    _isRefreshing = false;
    _refreshFuture = null;

    return result;
  }

  // ==================== ACTUAL REFRESH LOGIC ====================
  static Future<bool> _doRefresh() async {
    try {
      final refreshToken = await AppStorage.getWorkerRefreshToken();
      print("Refresh token from storage: '$refreshToken'");

      if (refreshToken == null || refreshToken.isEmpty) {
        await _forceLogout();
        return false;
      }

      if (!DeviceInfoService.isReady) {
        await DeviceInfoService.fetchDeviceInfo();
      }

      final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.refreshToken),
        headers: {
          "Authorization": "Bearer $refreshToken",
          "X-Device-Id":   DeviceInfoService.deviceId   ?? '',
          "X-Device-Name": DeviceInfoService.deviceName ?? '',
          "X-Device-Type": DeviceInfoService.deviceType ?? '',
          "X-Os-Version":  DeviceInfoService.osVersion  ?? '',
        },
      );

      print("AUTHORIZATION ::: $refreshToken");
      print("DEVICE ID ::: ${DeviceInfoService.deviceId}");
      print("DEVICE NAME ::: ${DeviceInfoService.deviceName}");
      print("DEVICE TYPE ::: ${DeviceInfoService.deviceType}");
      print("OS VERSION ::: ${DeviceInfoService.osVersion}");

      print("REFRESH TOKEN STATUS ::: ${response.statusCode}");
      print("REFRESH TOKEN BODY  ::: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final tokenData = data['data'];

        final newAccessToken  = tokenData['worker_access_token']  as String?;
        final newRefreshToken = tokenData['worker_refresh_token'] as String?;
        final workerId        = int.tryParse(tokenData['worker_id']?.toString() ?? '0') ?? 0;

        if (newAccessToken == null || newAccessToken.isEmpty) {
          await _forceLogout();
          return false;
        }

        await AppStorage.saveWorkerAuthData(
          accessToken:  newAccessToken,
          refreshToken: newRefreshToken ?? "",
          workerId:     workerId,
        );

        print("Worker tokens refreshed successfully");
        return true;

      } else {
        await _forceLogout();
        return false;
      }

    } catch (e) {
      print("REFRESH TOKEN ERROR ::: $e");
      await _forceLogout();
      return false;
    }
  }

  // ==================== FORCE LOGOUT ====================
  static Future<void> _forceLogout() async {
    try {
      FullScreenLoader.show();

      if (!DeviceInfoService.isReady) {
        await DeviceInfoService.fetchDeviceInfo();
      }

      final refreshToken = await AppStorage.getWorkerRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        CustomSnackbar.showError("Error", "Token missing. Please login again.");
        return;
      }

      final response = await LogoutApi.logout(
        token: refreshToken,
        xDeviceID: DeviceInfoService.deviceId!,
      );

      if (response["success"] == true) {
        await AppStorage.clearWorkerAuthData();
        Get.deleteAll(force: true);
        Get.offAllNamed(Routes.LOGIN);
      } else {
        CustomSnackbar.showError("Error", response["message"]);
      }
    } catch (e) {
      CustomSnackbar.showError("Logout Failed", e.toString());
    } finally {
      FullScreenLoader.hide();
    }
  }

}