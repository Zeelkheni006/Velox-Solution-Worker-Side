// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'app/modules/livelocation/live_location_controller.dart';
// import 'app/modules/livelocation/worker_status.dart';
// import 'app/routes/app_pages.dart';
// import 'core/utils/device_info_service.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await DeviceInfoService.fetchDeviceInfo();
//   Get.put(LiveLocationController(), permanent: true);
//   runApp(
//     AppLifecycleHandler(
//       child: MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Velox Partner',
//       debugShowCheckedModeBanner: false,
//
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//
//       initialRoute: AppPages.INITIAL,
//       getPages: AppPages.routes,
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/livelocation/live_location_controller.dart';
import 'app/routes/app_pages.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/theme_controller.dart';
import 'core/utils/device_info_service.dart';
import 'core/utils/security_service.dart';
import 'core/utils/app_lifecycle_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DeviceInfoService.fetchDeviceInfo();
  await SecurityService.runSecurityChecks();

  final themeCtrl = Get.put(ThemeController(), permanent: true);
  Get.put(LiveLocationController(), permanent: true);
  Get.put(ThemeController(), permanent: true);

  runApp(MyApp(themeCtrl: themeCtrl));
}

class MyApp extends StatelessWidget {
  final ThemeController themeCtrl;
  const MyApp({super.key, required this.themeCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mode = _resolveThemeMode(themeCtrl.themeMode.value);

      return AnimatedTheme(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        data: mode == ThemeMode.dark
            ? AppTheme.dark
            : AppTheme.light,
        child: GetMaterialApp(
          title: 'Velox Partner',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          builder: (context, child) =>
              AppLifecycleHandler(child: child!),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
        ),
      );
    });
  }

  ThemeMode _resolveThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}