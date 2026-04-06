class ApiUrl {

  // LIVE BASE URL //
  // static const String baseUrl = "https://api.veloxsolution.com";
  // static const String baseUrl = "http://72.61.245.134:8000";

  // ZEEL //
  // static const String baseUrl = "http://192.168.29.69:5000";


  // HARSH //
  static const String baseUrl = "http://192.168.29.164:5000";

  // AUTH //
  static const String LoginInitiate = "/api/v1/worker/auth/login/initiate";
  static const String LoginPassword = "/api/v1/worker/auth/login/through/password";
  static const String LoginOtp = "/api/v1/worker/auth/login/through/otp";
  static const String LoginOtpVerify = "/api/v1/worker/auth/login/through/otp/verify";

  // RESEND OTP //
  static const String loginresendotp = "/api/v1/worker/auth/login/through/otp/resend";

  // TODAY-UPCOMING-HISTORY ORDER //
  static const String todayorders = "/api/v1/worker/dashboard/orders/today";
  static const String upcomingorders = "/api/v1/worker/dashboard/orders/upcoming";
  static const String historyorders = "/api/v1/worker/dashboard/orders/history";
  static String orderDetails(int orderId) => "/api/v1/worker/dashboard/orders/$orderId";
  static const String closeorder = "/api/v1/worker/dashboard/orders/close-order";

  // LOGOUT //
  static const String logout = "/api/v1/worker/auth/logout";

  // PROFILE //
  static const String getuserprofiledata = "/api/v1/worker/profile/get";
  static const String changepassword = "/api/v1/worker/auth/change-password";

  // ORDER ASSIGN //
  static const String verifysendotp = "/api/v1/worker/dashboard/orders/verify/send-otp";
  static const String verifyconfirmotp = "/api/v1/worker/dashboard/orders/verify/confirm-otp";

  // WORKER-LEAVE //
  static const String workerleaverequest = "/api/v1/worker/time/off/request";
  static const String workerleavecheck = "/api/v1/worker/time/off/requests";
  static String workerLeaveRequestStatus(int requestId) => "/api/v1/worker/time/off/status?request_id=$requestId";
  static const String workerleavehistory = "/api/v1/worker/time/off/history";

  // WORKER LIVE LOCATION //
  static const String livelocationsend = "/api/v1/worker/live-location/ping";
  static const String workerstatus = "/api/v1/worker/live-location/status";

  // WORKER ORDER STATUS //
  static String workerOrderStatus(int orderId) => "/api/v1/worker/dashboard/orders/order-status/$orderId";
  static const String ordercomplete = "/api/v1/worker/dashboard/orders/complete";

  // RESCHEDULE SLOTS //
  static const String slotconfirm = "/api/v1/worker/dashboard/orders/reschedule/confirm";

  // ADDON ITEM //
  static const String addonItemSearch = "/api/v1/worker/dashboard/orders/addon-items";
  static const String addonAdd = "/api/v1/worker/dashboard/orders/addon-items/add";
  static const String addonRemove = "/api/v1/worker/dashboard/orders/addon-items/remove";
  static String addonItemShow(int orderId) => "/api/v1/worker/dashboard/orders/addon-items/$orderId";

}
