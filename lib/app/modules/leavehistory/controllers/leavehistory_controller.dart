import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/App_Safety/app_safety.dart';
import '../../../../core/api/Api_Service/Worker_Leave/worker_leave.dart';
import '../../../../core/utils/custome_snakbar.dart';

class LeavehistoryController extends GetxController {
  var isLoading = true.obs;
  var leaveList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaveHistory();
  }

  // ─────────────────────────────────────────────────
  /// 🔹 1️⃣ FETCH HISTORY (initial load — shows shimmer)
  // ─────────────────────────────────────────────────
  Future<void> fetchLeaveHistory() async {
    try {
      isLoading(true);

      final response = await WorkerLeaveApi.requestLeaveHistory();
      logPrint("LEAVE HISTORY ::: $response");

      final data = response['data'];

      if (data is List) {
        leaveList.assignAll(data.reversed.toList());
      } else {

        leaveList.clear();
        logPrint("LEAVE HISTORY: Data is not a list");
      }

    } catch (e) {
      // CustomSnackbar.showError('Error', e.toString());
      logPrint("LEAVE HISTORY ERROR ::: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  // ─────────────────────────────────────────────────
  /// 🔹 2️⃣ REFRESH HISTORY (pull-to-refresh — no shimmer)
  /// Called by RefreshIndicator's onRefresh callback.
  /// Does NOT set isLoading = true, so the shimmer
  /// skeleton is not shown — only the spinner appears.
  // ─────────────────────────────────────────────────
  Future<void> refreshHistory() async {
    try {
      final data = await WorkerLeaveApi.requestLeaveHistory();
      logPrint("LEAVE HISTORY REFRESHED ::: $data");
      leaveList.assignAll((data as List).reversed.toList());
    } catch (e) {
    }
  }
}