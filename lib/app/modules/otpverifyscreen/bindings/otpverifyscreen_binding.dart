import 'package:get/get.dart';

import '../controllers/otpverifyscreen_controller.dart';

class OtpverifyscreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpverifyscreenController>(
      () => OtpverifyscreenController(),
    );
  }
}
