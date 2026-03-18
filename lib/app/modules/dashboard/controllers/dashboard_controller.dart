// lib/features/dashboard/presentation/controllers/dashboard_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_storage.dart';

class DashboardController extends GetxController
    with GetSingleTickerProviderStateMixin {

  late TabController tabController;

  final isOnline = false.obs;
  final selectedIndex = 0.obs;

  final tabs = const [
    Tab(text: 'Today', icon: Icon(Icons.access_time_filled)),
    Tab(text: 'Upcoming', icon: Icon(Icons.schedule)),
    Tab(text: 'Old', icon: Icon(Icons.history)),
  ];

  @override
  Future<void> onInit() async {
    super.onInit();

    tabController = TabController(length: tabs.length, vsync: this);

    tabController.addListener(() {
      selectedIndex.value = tabController.index;
    });
    String? token = await AppStorage.getWorkerAccessToken();
    print("WORKER TOKEN ::: $token");
  }

  void goOnline() {
    isOnline.value = true;
    Get.snackbar(
      "Status Updated",
      "You are now Online!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }

  void goOffline() {
    isOnline.value = false;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
