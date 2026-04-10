import 'package:get/get.dart';

import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/forgotpassword/bindings/forgotpassword_binding.dart';
import '../modules/forgotpassword/views/forgotpassword_view.dart';
import '../modules/historyorderlist/bindings/historyorderlist_binding.dart';
import '../modules/historyorderlist/views/historyorderlist_view.dart';
import '../modules/leavehistory/bindings/leavehistory_binding.dart';
import '../modules/leavehistory/views/leavehistory_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/otpverifyscreen/bindings/otpverifyscreen_binding.dart';
import '../modules/otpverifyscreen/views/otpverifyscreen_view.dart';
import '../modules/passwordchange/bindings/passwordchange_binding.dart';
import '../modules/passwordchange/views/passwordchange_view.dart';
import '../modules/privacypolicy/bindings/privacypolicy_binding.dart';
import '../modules/privacypolicy/views/privacypolicy_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/todayorder/bindings/todayorder_binding.dart';
import '../modules/todayorder/views/todayorder_view.dart';
import '../modules/upcomingorderlist/bindings/upcomingorderlist_binding.dart';
import '../modules/upcomingorderlist/views/upcomingorderlist_view.dart';
import '../modules/workerleave/bindings/workerleave_binding.dart';
import '../modules/workerleave/views/workerleave_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.CURRENTORDERLIST,
      page: () => const TodayOrderView(),
      binding: TodayOrderBinding(),
    ),
    GetPage(
      name: _Paths.UPCOMINGORDERLIST,
      page: () => const UpcomingOrdersListView(),
      binding: UpcomingOrdersListBinding(),
    ),
    GetPage(
      name: _Paths.OLDORDERLIST,
      page: () => const HistoryOrdersListView(),
      binding: HistoryOrdersListBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.PASSWORDCHANGE,
      page: () => const PasswordchangeView(),
      binding: PasswordchangeBinding(),
    ),
    GetPage(
      name: _Paths.WORKERLEAVE,
      page: () => const WorkerleaveView(),
      binding: WorkerleaveBinding(),
    ),
    GetPage(
      name: _Paths.LEAVEHISTORY,
      page: () => const LeavehistoryView(),
      binding: LeavehistoryBinding(),
    ),
    GetPage(
      name: _Paths.OTPVERIFYSCREEN,
      page: () => const OtpverifyscreenView(),
      binding: OtpverifyscreenBinding(),
    ),
    GetPage(
      name: _Paths.FORGOTPASSWORD,
      page: () => const ForgotpasswordView(),
      binding: ForgotpasswordBinding(),
    ),
    GetPage(
      name: _Paths.PRIVACYPOLICY,
      page: () => const PrivacypolicyView(),
      binding: PrivacypolicyBinding(),
    ),
  ];
}
