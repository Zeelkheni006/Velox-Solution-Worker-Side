import 'package:get/get.dart';

import '../controllers/leavehistory_controller.dart';

class LeavehistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeavehistoryController>(
      () => LeavehistoryController(),
    );
  }
}
