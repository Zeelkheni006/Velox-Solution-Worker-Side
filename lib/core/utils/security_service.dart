import 'package:get/get.dart';
import 'package:safe_device/safe_device.dart';

class SecurityService {

  static Future<void> runSecurityChecks() async {

    /// ROOT CHECK
    bool isRooted = await SafeDevice.isJailBroken;

    if (isRooted) {
      Get.defaultDialog(
        title: "Security Alert",
        middleText: "Rooted device detected. App cannot run.",
      );
      return;
    }

    /// EMULATOR CHECK
    bool isRealDevice = await SafeDevice.isRealDevice;

    if (!isRealDevice) {
      Get.defaultDialog(
        title: "Security Alert",
        middleText: "Emulator detected. App cannot run.",
      );
      return;
    }

    /// TAMPER CHECK
    bool isSafe = await SafeDevice.isSafeDevice;

    if (!isSafe) {
      Get.snackbar(
        "Security Warning",
        "Unsafe device detected",
      );
    }
  }
}