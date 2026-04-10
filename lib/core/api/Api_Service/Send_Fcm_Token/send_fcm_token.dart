import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../../../App_Safety/app_safety.dart';
import '../../../utils/app_storage.dart';
import '../../../utils/device_info_service.dart';
import '../../api_endpoints.dart';

class NotificationPermissionHelper {

  static Future<String> getPermissionStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();

    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:   return "granted";
      case AuthorizationStatus.denied:       return "denied";
      case AuthorizationStatus.provisional:  return "default";
      default:                               return "unknown";
    }
  }
}

class SendFcmToken {

  static Future<Map<String, dynamic>> sendFcmToken() async {
    try {
      final token = await AppStorage.getWorkerAccessToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'No access token found'};
      }

      if (!DeviceInfoService.isReady) {
        await DeviceInfoService.fetchDeviceInfo();
      }

      final fcmToken = await FirebaseMessaging.instance.getToken();

      logPrint("FCM TOKEN ::: $fcmToken");

      if (fcmToken == null || fcmToken.isEmpty) {
        return {'success': false, 'message': 'FCM token not available'};
      }

      final workerId = await AppStorage.getWorkerId();
      final deviceIdWithUser = "${DeviceInfoService.deviceId ?? ''}_${workerId ?? ''}";
      final permissionStatus = await NotificationPermissionHelper.getPermissionStatus();

      final response = await http.post(
        Uri.parse(ApiUrl.baseUrl + ApiUrl.sendfcmtoken),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-device-id': DeviceInfoService.deviceId ?? '',
          'x-device-type': DeviceInfoService.deviceType ?? '',
          'x-device-name': DeviceInfoService.deviceName ?? '',
          'x-device-os-version': DeviceInfoService.osVersion ?? '',
        },
        body: jsonEncode({
          "device_id": deviceIdWithUser,
          "platform": DeviceInfoService.deviceType ?? 'android',
          "fcm_token": fcmToken,
          "permission_status": permissionStatus,
        }),
      );

      final responseData = jsonDecode(response.body);



      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': responseData};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Something went wrong'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}