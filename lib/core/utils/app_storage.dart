import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {

// ==================================================================================================== //
  // ==================== WORKER AUTH KEYS ====================
  static const String _workerAccessToken = 'worker_access_token';
  static const String _workerRefreshToken = 'worker_refresh_token';
  static const String _workerId = 'worker_id';
  static const String _isWorkerLoggedIn = 'is_worker_logged_in';

  // ==================== SAVE WORKER AUTH ====================
  static Future<void> saveWorkerAuthData({
    required String accessToken,
    required String refreshToken,
    required int workerId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_workerAccessToken, accessToken);
    await prefs.setString(_workerRefreshToken, refreshToken);
    await prefs.setInt(_workerId, workerId);
    await prefs.setBool(_isWorkerLoggedIn, true);

    print("✅ Worker auth data saved");
  }

  // ==================== GET WORKER DATA ====================
  static Future<String?> getWorkerAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_workerAccessToken);
  }

  static Future<String?> getWorkerRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_workerRefreshToken);
  }

  static Future<int?> getWorkerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_workerId);
  }

  static Future<bool> isWorkerLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isWorkerLoggedIn) ?? false;
  }

  // ==================== CLEAR WORKER DATA (LOGOUT) ====================
  static Future<void> clearWorkerAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_workerAccessToken);
    await prefs.remove(_workerRefreshToken);
    await prefs.remove(_workerId);
    await prefs.remove(_isWorkerLoggedIn);

    print("🗑️ Worker auth data cleared");
  }

// ==================================================================================================== //

  // ==================== OTP SESSION KEYS ====================
  static const String _otpExpiryTime = 'otp_expiry_time';
  static const String _otpOrderId = 'otp_order_id';

  // ==================== OTP SAVE ====================
  static Future<void> saveOtpSession({
    required int orderId,
    required int expiresInSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final expiry = DateTime.now()
        .add(Duration(seconds: expiresInSeconds))
        .millisecondsSinceEpoch;

    await prefs.setInt(_otpExpiryTime, expiry);
    await prefs.setInt(_otpOrderId, orderId);
  }

  static Future<bool> isOtpActive(int orderId) async {
    final prefs = await SharedPreferences.getInstance();

    final expiry = prefs.getInt(_otpExpiryTime);
    final savedOrderId = prefs.getInt(_otpOrderId);

    if (expiry == null || savedOrderId == null) return false;

    return savedOrderId == orderId &&
        DateTime.now().millisecondsSinceEpoch < expiry;
  }

  static Future<int?> getOtpRemainingSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt(_otpExpiryTime);

    if (expiry == null) return null;

    final remaining =
        (expiry - DateTime.now().millisecondsSinceEpoch) ~/ 1000;

    return remaining > 0 ? remaining : 0;
  }

  static Future<void> clearOtpSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_otpExpiryTime);
    await prefs.remove(_otpOrderId);
  }

}
