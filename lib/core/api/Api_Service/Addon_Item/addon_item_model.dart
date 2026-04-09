import 'dart:async';
import 'package:get/get.dart';
import '../../../../app/modules/orderdetails/controllers/order_details_controller.dart';
import '../../../../core/utils/custome_snakbar.dart';
import '../../../../core/api/Api_Service/Addon_Item/addon_item.dart';
import '../../../../core/api/api_endpoints.dart'; // for ApiUrl.baseUrl

// ─────────────────────────────────────────────────────────────────────────────
// Model — search result item
// ─────────────────────────────────────────────────────────────────────────────

class AddonPartModel {
  final int id;
  final String partName;
  final double amount;

  /// Relative path from API  e.g. "/static/images/addon_parts/xyz.webp"
  /// Use [imageUrl] to get the full URL.
  final String? itemImage;
  final bool isActive;
  final int quantity;

  const AddonPartModel({
    required this.id,
    required this.partName,
    required this.amount,
    this.itemImage,
    required this.isActive,
    required this.quantity,
  });

  /// Full URL ready for NetworkImage / Image.network
  String? get imageUrl =>
      (itemImage != null && itemImage!.isNotEmpty)
          ? '${ApiUrl.baseUrl}$itemImage'
          : null;

  factory AddonPartModel.fromJson(Map<String, dynamic> json) => AddonPartModel(
    id: json['id'] as int,
    partName: json['part_name'] as String,
    amount: (json['amount'] as num).toDouble(),
    itemImage: json['item_image'] as String?,
    isActive: json['is_active'] as bool? ?? true,
    quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Model — addon already attached to the order
// ─────────────────────────────────────────────────────────────────────────────

class OrderAddonModel {
  final int id;
  final int addonItemId;
  final String partName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderAddonModel({
    required this.id,
    required this.addonItemId,
    required this.partName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderAddonModel.fromJson(Map<String, dynamic> json) =>
      OrderAddonModel(
        id: json['id'] as int,
        addonItemId: json['addon_item_id'] as int,
        partName: json['part_name'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unit_price'] as num).toDouble(),
        totalPrice: (json['total_price'] as num).toDouble(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────

class AddonController extends GetxController {
  final int orderId;
  AddonController(this.orderId);

  // ── Search state ─────────────────────────────────────────────────────────
  var searchResults = <AddonPartModel>[].obs;
  var isSearching = false.obs;
  var searchQuery = ''.obs;

  /// True when the initial "load all" call is running (before user types).
  var isLoadingAll = false.obs;

  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 400);

  // ── Order addons state ────────────────────────────────────────────────────
  var orderAddons = <OrderAddonModel>[].obs;
  var isLoadingAddons = false.obs;
  var addonTotal = 0.0.obs;

  // ── Action state ──────────────────────────────────────────────────────────
  var addingPartId = RxnInt();
  var removingId = RxnInt();

  final RxBool isAddonExpanded = false.obs;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    // Load the order's current addons AND the default (all) item list in parallel.
    fetchOrderAddons();
    _loadAllItems();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  // ── Load all items (no search query) ─────────────────────────────────────

  Future<void> _loadAllItems() async {
    try {
      isLoadingAll(true);
      final res = await AddonItem.addOnItemGet(search: '');
      if (res['success'] == true) {
        final List items = res['data']?['Items'] ?? [];
        searchResults.assignAll(
          items.map((e) => AddonPartModel.fromJson(e)).toList(),
        );
      }
    } catch (_) {
      // Silently fail — user can still type to search manually.
    } finally {
      isLoadingAll(false);
    }
  }

  // ── Debounced search ──────────────────────────────────────────────────────

  void searchParts(String query) {
    searchQuery.value = query;
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      // Restore the full list without a network call if we already have it,
      // otherwise re-fetch.
      _debounce = Timer(_debounceDuration, _loadAllItems);
      return;
    }

    _debounce = Timer(_debounceDuration, () => _doSearch(query.trim()));
  }

  Future<void> _doSearch(String query) async {
    try {
      isSearching(true);
      final res = await AddonItem.addOnItemGet(search: query);
      if (res['success'] == true) {
        final List items = res['data']?['Items'] ?? [];
        searchResults.assignAll(
          items.map((e) => AddonPartModel.fromJson(e)).toList(),
        );
      } else {
        searchResults.clear();
      }
    } catch (_) {
      searchResults.clear();
    } finally {
      isSearching(false);
    }
  }

  // ── Fetch order addons ────────────────────────────────────────────────────

  Future<void> fetchOrderAddons() async {
    try {
      isLoadingAddons(true);
      final res = await AddonItem.addOnItemShow(orderId: orderId);
      if (res['success'] == true) {
        final msg = res['message'];
        final List items = msg['addon_items'] ?? [];
        orderAddons.assignAll(
          items.map((e) => OrderAddonModel.fromJson(e)).toList(),
        );
        addonTotal.value = (msg['addon_total'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (_) {
      // ignore
    } finally {
      isLoadingAddons(false);
    }
  }

  // ── Add part ──────────────────────────────────────────────────────────────

  Future<void> addPart(AddonPartModel part) async {
    try {
      addingPartId.value = part.id;
      final res = await AddonItem.addOnAdd(
        orderId: orderId,
        addonItemIds: [part.id],
        note: 'Parts added by worker',
      );

      if (res['success'] == true) {
        final msg = res['message'];
        final List items = msg['addon_items'] ?? [];
        orderAddons.assignAll(
          items.map((e) => OrderAddonModel.fromJson(e)).toList(),
        );
        addonTotal.value = (msg['addon_total'] as num?)?.toDouble() ??
            (msg['new_total_amount'] as num?)?.toDouble() ??
            0.0;

        CustomSnackbar.showSuccess(
          "Part Added",
          "${part.partName} added successfully",
        );

        _syncOrderTotal(msg);
      } else {
        CustomSnackbar.showError(
          "Error",
          res['message']?.toString() ?? "Failed to add part",
        );
      }
    } catch (_) {
      CustomSnackbar.showError("Error", "Something went wrong");
    } finally {
      addingPartId.value = null;
    }
  }

  // ── Remove part ───────────────────────────────────────────────────────────

  Future<void> removePart(OrderAddonModel addon) async {
    try {
      removingId.value = addon.id;

      final res = await AddonItem.addOnRemove(
        orderId: orderId,
        orderAddonItemId: addon.id,
      );

      if (res['success'] == true) {
        final msg = res['message'];

        final index = orderAddons.indexWhere((e) => e.id == addon.id);

        if (index != -1) {
          final current = orderAddons[index];

          if (current.quantity > 1) {
            /// ✅ ONLY DECREASE QUANTITY
            orderAddons[index] = OrderAddonModel(
              id: current.id,
              addonItemId: current.addonItemId,
              partName: current.partName,
              quantity: current.quantity - 1,
              unitPrice: current.unitPrice,
              totalPrice: current.unitPrice * (current.quantity - 1),
            );
          } else {
            /// ✅ REMOVE ONLY IF 1
            orderAddons.removeAt(index);
          }
        }

        /// ✅ UPDATE TOTAL
        addonTotal.value =
            (msg['addon_total'] as num?)?.toDouble() ?? addonTotal.value;

        CustomSnackbar.showSuccess(
          "Updated",
          "${addon.partName} updated",
        );

        _syncOrderTotal(msg);
      } else {
        CustomSnackbar.showError(
          "Error",
          res['message']?.toString() ?? "Failed",
        );
      }
    } catch (_) {
      CustomSnackbar.showError("Error", "Something went wrong");
    } finally {
      removingId.value = null;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void clearSearch() {
    _debounce?.cancel();
    searchQuery.value = '';
    _loadAllItems();
  }

  /// Keeps the parent OrderDetailsController's total amount in sync.
  void _syncOrderTotal(Map<String, dynamic> msg) {
    final newTotal =
    (msg['new_total_amount'] ?? msg['total_amount'])?.toDouble();
    if (newTotal == null) return;

    try {
      final orderCtrl = Get.find<OrderDetailsController>();
      final oldOrder = orderCtrl.order.value;
      if (oldOrder != null) {
        orderCtrl.order.value = oldOrder.copyWith(totalAmount: newTotal);
      }
    } catch (_) {
      // OrderDetailsController not in scope — safe to ignore.
    }
  }
}