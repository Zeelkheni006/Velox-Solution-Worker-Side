import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static String? deviceId;
  static String? deviceType;
  static String? deviceName;
  static String? osVersion;

  /// Call once (or when needed)
  static Future<void> fetchDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;

        deviceId = androidInfo.id;
        deviceType = 'android';
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
        osVersion = 'Android ${androidInfo.version.release}';
      }
      else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;

        deviceId = iosInfo.identifierForVendor;
        deviceType = 'ios';
        deviceName = iosInfo.name ?? iosInfo.model ?? 'iPhone';
        osVersion = 'iOS ${iosInfo.systemVersion}';
      }

      print('DEVICE ID ::: $deviceId');
      print('DEVICE TYPE ::: $deviceType');
      print('DEVICE NAME ::: $deviceName');
      print('OS VERSION ::: $osVersion');

    } catch (e) {
      print("DEVICE INFO ERROR ::: $e");
    }
  }

  static bool get isReady => deviceId != null;
}
