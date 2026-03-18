import 'package:get/get.dart';

import '../controllers/passwordchange_controller.dart';

class PasswordchangeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PasswordchangeController>(
      () => PasswordchangeController(),
    );
  }
}
