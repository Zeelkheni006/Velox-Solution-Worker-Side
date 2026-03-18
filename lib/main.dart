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
import 'core/utils/device_info_service.dart';
import 'core/utils/security_service.dart';
import 'core/utils/app_lifecycle_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DeviceInfoService.fetchDeviceInfo();

  /// Security checks
  await SecurityService.runSecurityChecks();

  Get.put(LiveLocationController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Velox Partner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),

      /// IMPORTANT
      builder: (context, child) {
        return AppLifecycleHandler(
          child: child!,
        );
      },

      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}