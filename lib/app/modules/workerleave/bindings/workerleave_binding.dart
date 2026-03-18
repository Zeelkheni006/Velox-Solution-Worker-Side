import 'package:get/get.dart';

import '../controllers/workerleave_controller.dart';

class WorkerleaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkerleaveController>(
      () => WorkerleaveController(),
    );
  }
}
