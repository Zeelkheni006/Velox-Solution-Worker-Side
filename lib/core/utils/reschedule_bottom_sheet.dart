// reschedule_bottom_sheet.dart
//
// ROOT CAUSE FIX:
// DraggableScrollableSheet + inner ScrollController + keyboard insets caused
// _StretchController to call setState() during layout → "Build scheduled during frame".
//
// SOLUTION: Replace DraggableScrollableSheet with a plain bottom sheet using
// ConstrainedBox + maxHeight. The inner SingleChildScrollView owns the only
// ScrollController, so there is zero conflict.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';
import '../../../../core/utils/custome_snakbar.dart';
import '../../../../core/utils/full_screen_loader.dart';
import '../../../../core/api/Api_Service/Reschedule_Slots/reschedule_slots.dart';
import '../../app/modules/orderdetails/controllers/order_details_controller.dart';
import '../../app/routes/app_pages.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local models
// ─────────────────────────────────────────────────────────────────────────────

class _SlotModel {
  final String startTime;
  final String endTime;
  const _SlotModel({required this.startTime, required this.endTime});

  String get label {
    String _fmt(String t) {
      final parts = t.split(':');
      final h = int.parse(parts[0]);
      final m = parts[1];
      final suffix = h < 12 ? 'AM' : 'PM';
      final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$h12:$m $suffix';
    }
    return '${_fmt(startTime)} – ${_fmt(endTime)}';
  }
}

class _DayModel {
  final String serviceDate;
  final List<_SlotModel> slots;
  const _DayModel({required this.serviceDate, required this.slots});

  String get displayDate {
    try {
      final d = DateTime.parse(serviceDate);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ];
      return '${days[d.weekday - 1]}, '
          '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]}';
    } catch (_) {
      return serviceDate;
    }
  }

  bool get isToday {
    try {
      final d = DateTime.parse(serviceDate);
      final now = DateTime.now();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    } catch (_) {
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Public entry point
// ─────────────────────────────────────────────────────────────────────────────

class RescheduleBottomSheet {
  static void show(
      BuildContext context, {
        required OrderDetailsController controller,
      }) {
    if (Get.isBottomSheetOpen == true) return;

    showModalBottomSheet(
      context: context,
      // isScrollControlled=true lets the sheet grow above 50% and also
      // means Flutter passes the correct viewInsets to the builder.
      isScrollControlled: true,
      isDismissible: true,
      // enableDrag=false: we handle scroll ourselves; letting the sheet
      // drag would fight the inner scroll and cause more _StretchController
      // assertion errors.
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _RescheduleSheet(controller: controller),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet widget
// ─────────────────────────────────────────────────────────────────────────────

class _RescheduleSheet extends StatefulWidget {
  final OrderDetailsController controller;
  const _RescheduleSheet({required this.controller});

  @override
  State<_RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<_RescheduleSheet> {
  // ── state ────────────────────────────────────────────────────────────────
  bool _isLoading = true;
  String? _error;
  List<_DayModel> _days = [];
  int _selectedDayIndex = 0;
  int? _selectedSlotIndex;

  // ── controllers ──────────────────────────────────────────────────────────
  final TextEditingController _noteCtrl = TextEditingController();
  final FocusNode _noteFocus = FocusNode();

  // Single ScrollController owned entirely by our SingleChildScrollView.
  // No DraggableScrollableSheet = no nested-scroll conflict.
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchSlots();

    _noteFocus.addListener(_onNoteFocusChange);
  }

  void _onNoteFocusChange() {
    if (!_noteFocus.hasFocus) return;
    // Give the keyboard time to finish animating in, then scroll to bottom.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _noteFocus
      ..removeListener(_onNoteFocusChange)
      ..dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── API: fetch available slots ────────────────────────────────────────────

  Future<void> _fetchSlots() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final res =
      await RescheduleSlots.rescheduleslot(widget.controller.orderId);
      if (res['success'] == true) {
        final rawDays = (res['message']?['days'] as List?) ?? [];
        setState(() {
          _days = rawDays.map((d) {
            final rawSlots = (d['available_slots'] as List?) ?? [];
            return _DayModel(
              serviceDate: d['service_date'] as String,
              slots: rawSlots
                  .map((s) => _SlotModel(
                startTime: s['slot_start_time'] as String,
                endTime: s['slot_end_time'] as String,
              ))
                  .toList(),
            );
          }).toList();
        });
      } else {
        setState(() {
          _error = res['message']?.toString() ?? 'Failed to load slots';
        });
      }
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── API: confirm reschedule ───────────────────────────────────────────────

  Future<void> _confirmReschedule() async {
    FocusScope.of(context).unfocus();

    if (_selectedSlotIndex == null) {
      CustomSnackbar.showError('Select Slot', 'Please choose a time slot.');
      return;
    }

    final note = _noteCtrl.text.trim();
    if (note.isEmpty) {
      CustomSnackbar.showError(
          'Reason Required', 'Please enter a reason for rescheduling.');
      // Re-focus and scroll after a tick so the keyboard animation
      // doesn't collide with the snackbar animation.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        FocusScope.of(context).requestFocus(_noteFocus);
      });
      return;
    }

    final day = _days[_selectedDayIndex];
    final slot = day.slots[_selectedSlotIndex!];

    FullScreenLoader.show(message: 'Rescheduling order...');

    try {
      final res = await RescheduleSlots.confirmslot(
        orderId: widget.controller.orderId,
        serviceDate: day.serviceDate,
        slotStartTime: slot.startTime,
        note: note,
      );

      FullScreenLoader.hide();

      if (res['success'] == true) {
        if (Navigator.canPop(context)) Navigator.of(context).pop();
        await Future.delayed(const Duration(milliseconds: 250));
        if (Get.context != null) {
          _showSuccessDialog(Get.context!, res['message'] as Map);
        }
      } else {
        final msg = res['message'];
        String errorMsg = 'Failed to reschedule';
        if (msg is Map) {
          final firstVal = msg.values.first;
          errorMsg = (firstVal is List && firstVal.isNotEmpty)
              ? firstVal.first.toString()
              : (msg['message']?.toString() ?? msg.toString());
        } else if (msg is String) {
          errorMsg = msg;
        }
        CustomSnackbar.showError('Error', errorMsg);
      }
    } catch (e) {
      FullScreenLoader.hide();
      print('RESCHEDULE CONFIRM ERROR ::: $e');
      CustomSnackbar.showError(
          'Error', 'Something went wrong. Please try again.');
    }
  }

  // ── Success dialog ────────────────────────────────────────────────────────

  void _showSuccessDialog(BuildContext ctx, Map message) {
    String _fmtTime(String? t) {
      if (t == null) return '';
      final parts = t.split(':');
      final h = int.parse(parts[0]);
      final m = parts[1];
      final suffix = h < 12 ? 'AM' : 'PM';
      final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$h12:$m $suffix';
    }

    String _fmtDate(String? d) {
      if (d == null) return '';
      try {
        final dt = DateTime.parse(d);
        const months = [
          'Jan','Feb','Mar','Apr','May','Jun',
          'Jul','Aug','Sep','Oct','Nov','Dec'
        ];
        const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
        return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
      } catch (_) {
        return d;
      }
    }

    final String msg =
        message['message']?.toString() ?? 'Order rescheduled successfully';
    final int newOrderId = message['new_order_id'] ?? 0;
    final String newStatus = message['new_order_status']?.toString() ?? '';
    final Map? newSlot =
    message['reschedule_request']?['new_slot'] as Map?;

    showDialog(
      context: ctx,
      barrierDismissible: false, // Prevents closing by tapping outside
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (dialogCtx) => _SuccessDialogContent(
        message: msg,
        newOrderId: newOrderId,
        newStatus: newStatus,
        dateLabel: _fmtDate(newSlot?['service_date']?.toString()),
        timeLabel: newSlot != null
            ? '${_fmtTime(newSlot['slot_start_time']?.toString())} – '
            '${_fmtTime(newSlot['slot_end_time']?.toString())}'
            : '',
        onDone: () async {
          Navigator.of(dialogCtx).pop();
          Get.offAllNamed(Routes.DASHBOARD);
          await Get.find<OrderDetailsController>().fetchOrderDetails();
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // viewInsets.bottom = keyboard height.
    // We use Padding (not AnimatedPadding) here because the framework
    // already animates viewInsets changes and double-animating causes jank.
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    // Sheet occupies at most 88% of the screen height, minus keyboard.
    // This gives natural feel: keyboard pushes the sheet content up
    // so the note field is always visible.
    final maxSheetHeight = screenHeight * 0.88 - keyboardHeight;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: GestureDetector(
        // Tapping outside the note field dismisses keyboard
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxSheetHeight < 200 ? 200 : maxSheetHeight,
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(rs(context, 28)),
                  topRight: Radius.circular(rs(context, 28)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag handle ─────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.only(top: rs(context, 12)),
                    child: CustomContainer(
                      width: rs(context, 40),
                      height: rs(context, 4),
                      backgroundColor:
                      AppColors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(rs(context, 10)),
                    ),
                  ),

                  // ── Header ──────────────────────────────────────────
                  _buildHeader(context),
                  const Divider(height: 1),

                  // ── Scrollable body ─────────────────────────────────
                  // Flexible so Column doesn't overflow; the scroll view
                  // fills whatever space is left between header and CTA.
                  Flexible(
                    child: _isLoading
                        ? _buildShimmer(context)
                        : _error != null
                        ? _buildError(context)
                        : _buildScrollBody(context),
                  ),

                  // ── Bottom CTA ──────────────────────────────────────
                  if (!_isLoading && _error == null)
                    _buildBottomBar(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        rs(context, 20), rs(context, 14),
        rs(context, 20), rs(context, 14),
      ),
      child: Row(
        children: [
          CustomContainer(
            padding: EdgeInsets.all(rs(context, 10)),
            backgroundColor: AppColors.warning.withOpacity(0.12),
            borderRadius: BorderRadius.circular(100),
            child: Icon(Icons.event_repeat_rounded,
                color: AppColors.warning, size: rs(context, 22)),
          ),
          SizedBox(width: rs(context, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reschedule Order',
                    style: AppTextStyles.heading4(context)
                        .copyWith(fontWeight: FontWeight.bold)),
                Text('Pick a new date and time slot',
                    style: AppTextStyles.bodySmall(context)
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: CustomContainer(
              padding: EdgeInsets.all(rs(context, 8)),
              backgroundColor: AppColors.textSecondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(100),
              child: Icon(Icons.close_rounded,
                  size: rs(context, 18), color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shimmer ───────────────────────────────────────────────────────────────

  Widget _buildShimmer(BuildContext context) {
    return SingleChildScrollView(
      // NeverScrollableScrollPhysics so the shimmer doesn't itself scroll
      // and never creates a _StretchController interaction.
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(rs(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmer(context, width: rs(context, 110), height: rs(context, 16)),
          SizedBox(height: rs(context, 12)),
          // Day chips row
          SizedBox(
            height: rs(context, 72),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => SizedBox(width: rs(context, 8)),
              itemBuilder: (_, __) => _shimmer(context,
                  width: rs(context, 76),
                  height: rs(context, 72),
                  radius: 14),
            ),
          ),
          SizedBox(height: rs(context, 22)),
          _shimmer(context, width: rs(context, 130), height: rs(context, 16)),
          SizedBox(height: rs(context, 12)),
          // Slot grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: rs(context, 10),
              crossAxisSpacing: rs(context, 10),
              childAspectRatio: 2.7,
            ),
            itemCount: 4,
            itemBuilder: (_, __) =>
                _shimmer(context, height: double.infinity, radius: 12),
          ),
          SizedBox(height: rs(context, 22)),
          _shimmer(context, width: rs(context, 150), height: rs(context, 16)),
          SizedBox(height: rs(context, 12)),
          _shimmer(context, height: rs(context, 88), radius: 14),
        ],
      ),
    );
  }

  Widget _shimmer(BuildContext context,
      {double? width, required double height, double radius = 8}) {
    return _ShimmerBox(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rs(context, radius)),
        ),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(rs(context, 24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: rs(context, 48),
                color: AppColors.error.withOpacity(0.5)),
            SizedBox(height: rs(context, 12)),
            Text(_error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(context)
                    .copyWith(color: AppColors.textSecondary)),
            SizedBox(height: rs(context, 20)),
            GestureDetector(
              onTap: _fetchSlots,
              child: CustomContainer(
                padding: EdgeInsets.symmetric(
                    horizontal: rs(context, 24),
                    vertical: rs(context, 12)),
                backgroundColor: AppColors.primary,
                borderRadius: AppRadii.button(context),
                child: Text('Retry',
                    style: AppTextStyles.buttonMedium(context)
                        .copyWith(color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Scrollable body ───────────────────────────────────────────────────────

  Widget _buildScrollBody(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollCtrl,
      // ClampingScrollPhysics = no overscroll stretch on Android.
      // This is the KEY fix: BouncingScrollPhysics / default physics on
      // Android create the _StretchController that caused the assertion.
      physics: const ClampingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        rs(context, 16), rs(context, 16),
        rs(context, 16), rs(context, 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, Icons.calendar_month_rounded, 'Select Date'),
          SizedBox(height: rs(context, 10)),
          _buildDayRow(context),
          SizedBox(height: rs(context, 20)),
          _label(context, Icons.schedule_rounded, 'Select Time Slot'),
          SizedBox(height: rs(context, 10)),
          _buildSlotGrid(context),
          SizedBox(height: rs(context, 20)),
          // Note — required
          Row(children: [
            Icon(Icons.notes_rounded,
                size: rs(context, 16), color: AppColors.primary),
            SizedBox(width: rs(context, 6)),
            Text('Reason for Reschedule',
                style: AppTextStyles.bodyMedium(context)
                    .copyWith(fontWeight: FontWeight.w700)),
            SizedBox(width: rs(context, 6)),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: rs(context, 6), vertical: rs(context, 2)),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(rs(context, 6)),
              ),
              child: Text('Required',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                    fontSize: rs(context, 10),
                  )),
            ),
          ]),
          SizedBox(height: rs(context, 10)),
          _buildNoteField(context),
          // Extra bottom padding so content isn't hidden behind the CTA bar
          SizedBox(height: rs(context, 20)),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: rs(context, 16), color: AppColors.primary),
      SizedBox(width: rs(context, 6)),
      Text(text,
          style: AppTextStyles.bodyMedium(context)
              .copyWith(fontWeight: FontWeight.w700)),
    ]);
  }

  // ── Day selector (horizontal) ─────────────────────────────────────────────

  Widget _buildDayRow(BuildContext context) {
    return SizedBox(
      height: rs(context, 72),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // ClampingScrollPhysics here too — keeps all horizontal lists
        // free of _StretchController.
        physics: const ClampingScrollPhysics(),
        itemCount: _days.length,
        separatorBuilder: (_, __) => SizedBox(width: rs(context, 8)),
        itemBuilder: (_, i) {
          final day = _days[i];
          final sel = _selectedDayIndex == i;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedDayIndex = i;
              _selectedSlotIndex = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: rs(context, 76),
              decoration: BoxDecoration(
                color: sel
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(rs(context, 14)),
                border: Border.all(
                  color: sel
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.18),
                  width: sel ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (day.isToday)
                    Text('TODAY',
                        style: AppTextStyles.bodySmall(context).copyWith(
                          fontSize: rs(context, 9),
                          fontWeight: FontWeight.w800,
                          color: sel
                              ? AppColors.white.withOpacity(0.8)
                              : AppColors.primary,
                          letterSpacing: 0.5,
                        )),
                  Text(
                    day.displayDate.split(', ').first,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      fontWeight: FontWeight.w600,
                      color: sel
                          ? AppColors.white.withOpacity(0.85)
                          : AppColors.textSecondary,
                      fontSize: rs(context, 11),
                    ),
                  ),
                  Text(
                    day.displayDate.split(', ').last,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: sel ? AppColors.white : AppColors.textPrimary,
                      fontSize: rs(context, 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Slot grid ─────────────────────────────────────────────────────────────

  Widget _buildSlotGrid(BuildContext context) {
    final slots =
    _days.isNotEmpty ? _days[_selectedDayIndex].slots : <_SlotModel>[];

    if (slots.isEmpty) {
      return CustomContainer(
        width: double.infinity,
        padding: EdgeInsets.all(rs(context, 20)),
        backgroundColor: AppColors.textSecondary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(rs(context, 14)),
        child: Text('No slots available for this date',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(color: AppColors.textSecondary)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: rs(context, 10),
        crossAxisSpacing: rs(context, 10),
        childAspectRatio: 2.7,
      ),
      itemCount: slots.length,
      itemBuilder: (_, i) {
        final slot = slots[i];
        final sel = _selectedSlotIndex == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlotIndex = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: sel
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.textSecondary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(rs(context, 12)),
              border: Border.all(
                color: sel
                    ? AppColors.primary
                    : AppColors.textSecondary.withOpacity(0.18),
                width: sel ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  sel
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: rs(context, 15),
                  color: sel
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.5),
                ),
                SizedBox(width: rs(context, 5)),
                Text(slot.label,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: sel ? AppColors.primary : AppColors.textPrimary,
                      fontSize: rs(context, 11),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Note field ────────────────────────────────────────────────────────────

  Widget _buildNoteField(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _noteCtrl,
      builder: (_, value, __) {
        final empty = value.text.trim().isEmpty;
        return TextField(
          controller: _noteCtrl,
          focusNode: _noteFocus,
          maxLines: 3,
          maxLength: 200,
          style: AppTextStyles.bodyMedium(context),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            hintText:
            'e.g. "User not available at the scheduled time"',
            hintStyle: AppTextStyles.bodySmall(context).copyWith(
                color: AppColors.textSecondary.withOpacity(0.45)),
            filled: true,
            fillColor: empty
                ? AppColors.error.withOpacity(0.03)
                : AppColors.textSecondary.withOpacity(0.06),
            counterStyle: AppTextStyles.bodySmall(context)
                .copyWith(color: AppColors.textSecondary.withOpacity(0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs(context, 14)),
              borderSide: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.18)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs(context, 14)),
              borderSide: BorderSide(
                color: empty
                    ? AppColors.error.withOpacity(0.4)
                    : AppColors.textSecondary.withOpacity(0.18),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(rs(context, 14)),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.all(rs(context, 14)),
            suffixIcon: Padding(
              padding: EdgeInsets.only(right: rs(context, 10)),
              child: Icon(
                empty
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: empty
                    ? AppColors.error.withOpacity(0.5)
                    : AppColors.success,
                size: rs(context, 18),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Bottom CTA bar ────────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _noteCtrl,
      builder: (_, value, __) {
        final canConfirm =
            _selectedSlotIndex != null && value.text.trim().isNotEmpty;
        return Container(
          padding: EdgeInsets.fromLTRB(
            rs(context, 16), rs(context, 12),
            rs(context, 16), rs(context, 24),
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
                top: BorderSide(
                    color: AppColors.textSecondary.withOpacity(0.1))),
          ),
          child: GestureDetector(
            onTap: _confirmReschedule,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
              EdgeInsets.symmetric(vertical: rs(context, 16)),
              decoration: BoxDecoration(
                color: canConfirm
                    ? AppColors.warning.withOpacity(0.9)
                    : AppColors.textSecondary.withOpacity(0.15),
                borderRadius: AppRadii.button(context),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_rounded,
                      color: canConfirm
                          ? AppColors.white
                          : AppColors.textSecondary),
                  SizedBox(width: rs(context, 8)),
                  Text(
                    canConfirm
                        ? 'Confirm Reschedule'
                        : 'Select slot & add reason',
                    style: AppTextStyles.buttonMedium(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: canConfirm
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer widget — no external package
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final Widget child;
  const _ShimmerBox({required this.child});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            Color(0xFFE4E4E4),
            Color(0xFFEEEEEE),
            Color(0xFFF8F8F8),
            Color(0xFFEEEEEE),
            Color(0xFFE4E4E4),
          ],
          stops: [
            0.0,
            (_anim.value - 0.3).clamp(0.0, 1.0),
            _anim.value.clamp(0.0, 1.0),
            (_anim.value + 0.3).clamp(0.0, 1.0),
            1.0,
          ],
        ).createShader(bounds),
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Success dialog content
// ─────────────────────────────────────────────────────────────────────────────

// _SuccessDialogContent - Modified version

class _SuccessDialogContent extends StatelessWidget {
  final String message;
  final int newOrderId;
  final String newStatus;
  final String dateLabel;
  final String timeLabel;
  final VoidCallback onDone;

  const _SuccessDialogContent({
    required this.message,
    required this.newOrderId,
    required this.newStatus,
    required this.dateLabel,
    required this.timeLabel,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: CustomContainer(
          backgroundColor: AppColors.surface,
          borderRadius: BorderRadius.circular(rs(context, 24)),
          padding: EdgeInsets.all(rs(context, 24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomContainer(
                padding: EdgeInsets.all(rs(context, 18)),
                backgroundColor: AppColors.success.withOpacity(0.12),
                borderRadius: BorderRadius.circular(100),
                child: Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.success, size: rs(context, 44)),
              ),
              SizedBox(height: rs(context, 16)),
              Text('Order Rescheduled!',
                  style: AppTextStyles.heading4(context).copyWith(
                      fontWeight: FontWeight.bold, color: AppColors.success)),
              SizedBox(height: rs(context, 6)),
              Text(message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(context)
                      .copyWith(color: AppColors.textSecondary)),
              SizedBox(height: rs(context, 20)),
              CustomContainer(
                width: double.infinity,
                padding: EdgeInsets.all(rs(context, 16)),
                backgroundColor: AppColors.success.withOpacity(0.06),
                borderRadius: BorderRadius.circular(rs(context, 16)),
                border: Border.all(color: AppColors.success.withOpacity(0.2)),
                child: Column(children: [
                  if (dateLabel.isNotEmpty)
                    _row(context, Icons.calendar_today_rounded, 'New Date', dateLabel),
                  if (dateLabel.isNotEmpty && timeLabel.isNotEmpty)
                    Divider(height: rs(context, 16), color: AppColors.success.withOpacity(0.15)),
                  if (timeLabel.isNotEmpty)
                    _row(context, Icons.schedule_rounded, 'New Slot', timeLabel),
                  if (newOrderId > 0) ...[
                    Divider(height: rs(context, 16), color: AppColors.success.withOpacity(0.15)),
                    _row(context, Icons.tag_rounded, 'New Order ID', '#$newOrderId'),
                  ],
                  if (newStatus.isNotEmpty) ...[
                    Divider(height: rs(context, 16), color: AppColors.success.withOpacity(0.15)),
                    _row(context, Icons.info_outline_rounded, 'Status',
                        newStatus[0].toUpperCase() + newStatus.substring(1)),
                  ],
                ]),
              ),
              SizedBox(height: rs(context, 20)),
              GestureDetector(
                onTap: onDone,
                child: CustomContainer(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: rs(context, 15)),
                  backgroundColor: AppColors.primary,
                  borderRadius: AppRadii.button(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_rounded,
                          color: AppColors.white, size: rs(context, 20)),
                      SizedBox(width: rs(context, 8)),
                      Text('Go to Home Page',
                          style: AppTextStyles.buttonMedium(context).copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
      BuildContext context, IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: rs(context, 16), color: AppColors.success),
      SizedBox(width: rs(context, 8)),
      Text('$label:',
          style: AppTextStyles.bodySmall(context).copyWith(
              color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      SizedBox(width: rs(context, 6)),
      Expanded(
        child: Text(value,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodySmall(context).copyWith(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
    ]);
  }
}