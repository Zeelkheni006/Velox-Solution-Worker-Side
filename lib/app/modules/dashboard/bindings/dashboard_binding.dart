// lib/features/dashboard/presentation/bindings/dashboard_binding.dart

import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
