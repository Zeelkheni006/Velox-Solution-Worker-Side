import 'package:get/get.dart';
import '../../../../core/utils/app_storage.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {

  Future<void> checkLoginAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3));

    final accessToken = await AppStorage.getWorkerAccessToken();
    final refreshToken = await AppStorage.getWorkerRefreshToken();

    if (accessToken != null && accessToken.isNotEmpty && refreshToken != null && refreshToken.isNotEmpty) {

      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
