import 'package:get/get.dart';
import '../../../../core/api/Api_Service/Worker_Leave/worker_leave.dart';

class LeavehistoryController extends GetxController {
  var isLoading = true.obs;
  var leaveList = <dynamic>[].obs;

  @override
  void onInit() {
    fetchLeaveHistory();
    super.onInit();
  }

  void fetchLeaveHistory() async {
    try {
      isLoading(true);
      final data = await WorkerLeaveApi.requestLeaveHistory();
      print("LEAVE HISTORY ::: ${data}");
      leaveList.assignAll(data.reversed.toList());
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
