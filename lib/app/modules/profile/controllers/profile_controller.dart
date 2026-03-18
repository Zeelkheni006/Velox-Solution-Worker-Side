import 'package:get/get.dart';
import '../../../../core/api/Api_Service/Logout/logout.dart';
import '../../../../core/api/Api_Service/Profile/profile.dart';
import '../../../../core/utils/app_storage.dart';
import '../../../../core/utils/custome_snakbar.dart';
import '../../../../core/utils/device_info_service.dart';
import '../../../../core/utils/full_screen_loader.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  RxMap<String, dynamic> worker = <String, dynamic>{}.obs;
  RxBool isOnline = false.obs;
  RxInt completedJobsCount = 0.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;

      final response = await ProfileApi.getProfileData();

      if (response["success"]) {
        worker.value = response["data"];
      } else {
        CustomSnackbar.showError("Error", response["message"]);
      }
    } catch (e) {
      CustomSnackbar.showError("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void toggleStatus(bool value) {
    isOnline.value = value;
  }

  Future<void> logout() async {
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
