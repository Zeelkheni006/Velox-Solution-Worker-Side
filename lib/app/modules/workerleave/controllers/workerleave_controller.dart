import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_service/Worker_Leave/worker_leave.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/custome_snakbar.dart';
import '../../../../core/utils/full_screen_loader.dart';

class WorkerleaveController extends GetxController {
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final reasonController = TextEditingController();

  final isLoading = false.obs;

  /// UI Control
  final showStatusUI = false.obs;

  /// Status Data
  final statusText = ''.obs;
  final statusStart = ''.obs;
  final statusEnd = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkExistingLeave();
  }

  // ─────────────────────────────────────────────────
  /// 🔹 1️⃣ CHECK EXISTING REQUEST
  // ─────────────────────────────────────────────────
  Future<void> checkExistingLeave() async {
    try {
      isLoading.value = true;

      final response = await WorkerLeaveApi.workerLeaveCheck();

      if (response['success'] == true) {
        final message = response['message'];

        if (message is List && message.isNotEmpty) {
          final requestId = message[0]['request_id'];
          await fetchLeaveStatus(requestId);
        } else {
          showStatusUI.value = false;
        }
      }
    } catch (e) {
      debugPrint("Check Leave Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────
  /// 🔹 2️⃣ FETCH STATUS
  // ─────────────────────────────────────────────────
  Future<void> fetchLeaveStatus(int requestId) async {
    try {
      final response =
      await WorkerLeaveApi.workerLeaveRequestStatus(requestId);

      if (response['success'] == true) {
        final data = response['message'];

        statusText.value = data['status'] ?? '';
        statusStart.value = data['start_datetime'] ?? '';
        statusEnd.value = data['end_datetime'] ?? '';

        showStatusUI.value = true;
      }
    } catch (e) {
      debugPrint("Status Error: $e");
    }
  }

  // ─────────────────────────────────────────────────
  /// 🔹 3️⃣ SUBMIT LEAVE
  // ─────────────────────────────────────────────────
  Future<void> submitLeave() async {
    if (startDate.value == null || endDate.value == null) {
      CustomSnackbar.showError('Error', 'Please select date & time');
      return;
    }

    if (reasonController.text.trim().isEmpty) {
      CustomSnackbar.showError('Error', 'Please enter reason');
      return;
    }

    try {
      FullScreenLoader.show(message: 'Submitting leave request...');

      final response = await WorkerLeaveApi.requestLeave(
        startDatetime: startDate.value!.toIso8601String(),
        endDatetime: endDate.value!.toIso8601String(),
        reason: reasonController.text.trim(),
      );

      FullScreenLoader.hide();

      if (response['success'] == true) {
        final requestId = response['data']['request_id'];

        await fetchLeaveStatus(requestId);

        CustomSnackbar.showSuccess(
          'Success',
          response['message'] ?? 'Leave requested',
        );
      } else {
        CustomSnackbar.showError(
          'Failed',
          response['message'] ?? 'Something went wrong',
        );
      }
    } catch (e) {
      FullScreenLoader.hide();
      CustomSnackbar.showError('Error', e.toString());
    }
  }

  // ─────────────────────────────────────────────────
  /// 🔹 4️⃣ PULL TO REFRESH
  /// Called by RefreshIndicator's onRefresh callback.
  /// Silently re-checks leave status without showing
  /// the full shimmer loader.
  // ─────────────────────────────────────────────────
  Future<void> refreshLeave() async {
    try {
      final response = await WorkerLeaveApi.workerLeaveCheck();

      if (response['success'] == true) {
        final message = response['message'];

        if (message is List && message.isNotEmpty) {
          final requestId = message[0]['request_id'];
          await fetchLeaveStatus(requestId);
        } else {
          /// No pending leave — reset to form view
          showStatusUI.value = false;
          statusText.value = '';
          statusStart.value = '';
          statusEnd.value = '';
        }
      }

    } catch (e) {
      debugPrint("Refresh Error: $e");
    }
  }

  // ─────────────────────────────────────────────────
  /// 🔹 5️⃣ DATE & TIME PICKER
  // ─────────────────────────────────────────────────
  Future<void> pickDateTime(BuildContext context, bool isStart) async {
    DateTime initialDate = DateTime.now();
    TimeOfDay initialTime = TimeOfDay.now();
    DateTime firstDate = DateTime.now();

    /// If END time & startDate already selected
    if (!isStart && startDate.value != null) {
      final startPlusOneMinute =
      startDate.value!.add(const Duration(minutes: 1));

      initialDate = startPlusOneMinute;
      firstDate = startPlusOneMinute;
      initialTime = TimeOfDay.fromDateTime(startPlusOneMinute);
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.secondary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    /// Extra safety: end time should not be <= start time
    if (!isStart &&
        startDate.value != null &&
        dateTime
            .isBefore(startDate.value!.add(const Duration(minutes: 1)))) {
      CustomSnackbar.showError(
        'Invalid Time',
        'End time must be after start time',
      );
      return;
    }

    if (isStart) {
      startDate.value = dateTime;
      endDate.value = null; // reset end time when start changes
    } else {
      endDate.value = dateTime;
    }
  }

  @override
  void onClose() {
    reasonController.dispose();
    super.onClose();
  }
}