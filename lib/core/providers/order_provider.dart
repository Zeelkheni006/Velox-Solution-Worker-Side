import 'package:flutter/foundation.dart';
import '../../data/models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  // Static orders that stay consistent
  final List<OrderModel> _staticCurrentOrders = [
    OrderModel(
      id: 'ORD1001',
      serviceName: 'AC Deep Cleaning Service',
      customerName: 'Aarav Patel',
      customerPhone: '+919510008081',
      status: 'TRAVELING',
      scheduledTime: DateTime.now().add(const Duration(minutes: 10)),
      customerLat: 21.1702,
      customerLon: 72.8311,
      customerAddress: 'Flat 401, Sapphire Towers, Ring Road, Surat.',
      totalAmount: 1250.00,
      paymentStatus: 'PAID_ONLINE',
      startOtp: '1234',
    ),
    OrderModel(
      id: 'ORD1002',
      serviceName: 'Home Salon - Haircut',
      customerName: 'Priya Sharma',
      customerPhone: '+919510008081',
      status: 'ACCEPTED',
      scheduledTime: DateTime.now().add(const Duration(minutes: 45)),
      customerLat: 21.1800,
      customerLon: 72.8400,
      customerAddress: 'Bungalow 7, Greenwoods Colony, Adajan, Surat.',
      totalAmount: 750.00,
      paymentStatus: 'CASH_COLLECT',
      startOtp: '5678',
    ),
  ];

  final List<OrderModel> _staticUpcomingOrders = [
    OrderModel(
      id: 'ORD1003',
      serviceName: 'Sofa & Carpet Cleaning',
      customerName: 'Kajal Desai',
      customerPhone: '+919000300030',
      status: 'NEW',
      scheduledTime: DateTime.now().add(const Duration(hours: 3)),
      customerLat: 21.2000,
      customerLon: 72.8500,
      customerAddress: '102, Shanti Residency, Pal Gam, Surat.',
      totalAmount: 3500.00,
      paymentStatus: 'PAID_ONLINE',
      startOtp: '9012',
    ),
    OrderModel(
      id: 'ORD1004',
      serviceName: 'Geyser Repair',
      customerName: 'Jainish Shah',
      customerPhone: '+919000400040',
      status: 'NEW',
      scheduledTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
      customerLat: 21.1500,
      customerLon: 72.8100,
      customerAddress: 'Block C, Silver Complex, Vesu, Surat.',
      totalAmount: 800.00,
      paymentStatus: 'CASH_COLLECT',
      startOtp: '3456',
    ),
  ];

  final List<OrderModel> _staticOldOrders = [
    OrderModel(
      id: 'ORD0999',
      serviceName: 'Plumbing Service - Leak Fix',
      customerName: 'Hemant Gupta',
      customerPhone: '+919000500050',
      status: 'COMPLETED',
      scheduledTime: DateTime(2025, 1, 10, 14, 0),
      customerLat: 21.1600,
      customerLon: 72.8200,
      customerAddress: 'Gala 3, City Center Mall, Near Station, Surat.',
      totalAmount: 500.00,
      paymentStatus: 'CASH_COLLECT',
    ),
    OrderModel(
      id: 'ORD0998',
      serviceName: 'Pest Control (Cancelled)',
      customerName: 'Falguni Shah',
      customerPhone: '+919000600060',
      status: 'CANCELLED',
      scheduledTime: DateTime(2025, 1, 9, 11, 30),
      customerLat: 21.1900,
      customerLon: 72.8000,
      customerAddress: 'Tower B, Galaxy Apartments, Paldi, Surat.',
      totalAmount: 2200.00,
      paymentStatus: 'PAID_ONLINE',
      cancellationReason: 'Customer cancelled',
    ),
  ];

  // Dynamic lists
  List<OrderModel> _currentOrders = [];
  List<OrderModel> _upcomingOrders = [];
  List<OrderModel> _oldOrders = [];
  int _completedJobsCount = 0;

  OrderProvider() {
    // Initialize with static data
    _currentOrders = List.from(_staticCurrentOrders);
    _upcomingOrders = List.from(_staticUpcomingOrders);
    _oldOrders = List.from(_staticOldOrders);
    _completedJobsCount = _oldOrders.where((o) => o.status == 'COMPLETED').length;
  }

  List<OrderModel> get currentOrders => _currentOrders;
  List<OrderModel> get upcomingOrders => _upcomingOrders;
  List<OrderModel> get oldOrders => _oldOrders;
  int get completedJobsCount => _completedJobsCount;

  // Accept order from upcoming
  void acceptOrder(String orderId) {
    final orderIndex = _upcomingOrders.indexWhere((o) => o.id == orderId);
    if (orderIndex != -1) {
      final order = _upcomingOrders[orderIndex];
      final updatedOrder = order.copyWith(status: 'ACCEPTED');

      _upcomingOrders.removeAt(orderIndex);
      _currentOrders.add(updatedOrder);
      notifyListeners();
    }
  }

  // Update order status
  void updateOrderStatus(String orderId, String newStatus) {
    final currentIndex = _currentOrders.indexWhere((o) => o.id == orderId);

    if (currentIndex != -1) {
      final order = _currentOrders[currentIndex];
      final updatedOrder = order.copyWith(status: newStatus);
      _currentOrders[currentIndex] = updatedOrder;
      notifyListeners();
    }
  }

  // Complete order and move to old orders
  void completeOrder(String orderId, {String? photoUrl}) {
    final orderIndex = _currentOrders.indexWhere((o) => o.id == orderId);
    if (orderIndex != -1) {
      final order = _currentOrders[orderIndex];
      final completedOrder = order.copyWith(
        status: 'COMPLETED',
        completionPhotoUrl: photoUrl,
      );

      _currentOrders.removeAt(orderIndex);
      _oldOrders.insert(0, completedOrder);
      _completedJobsCount++;
      notifyListeners();
    }
  }

  // Cancel order
  void cancelOrder(String orderId, String reason) {
    final orderIndex = _currentOrders.indexWhere((o) => o.id == orderId);
    if (orderIndex != -1) {
      final order = _currentOrders[orderIndex];
      final cancelledOrder = order.copyWith(
        status: 'CANCELLED',
        cancellationReason: reason,
      );

      _currentOrders.removeAt(orderIndex);
      _oldOrders.insert(0, cancelledOrder);
      notifyListeners();
    }
  }

  // Get order by ID
  OrderModel? getOrderById(String orderId) {
    try {
      return _currentOrders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      try {
        return _upcomingOrders.firstWhere((o) => o.id == orderId);
      } catch (e) {
        try {
          return _oldOrders.firstWhere((o) => o.id == orderId);
        } catch (e) {
          return null;
        }
      }
    }
  }
}

// Extension for OrderModel copyWith
extension OrderModelExtension on OrderModel {
  OrderModel copyWith({
    String? status,
    String? completionPhotoUrl,
    String? cancellationReason,
  }) {
    return OrderModel(
      id: id,
      serviceName: serviceName,
      customerName: customerName,
      customerPhone: customerPhone,
      status: status ?? this.status,
      scheduledTime: scheduledTime,
      customerLat: customerLat,
      customerLon: customerLon,
      customerAddress: customerAddress,
      totalAmount: totalAmount,
      paymentStatus: paymentStatus,
      startOtp: startOtp,
      completionPhotoUrl: completionPhotoUrl ?? this.completionPhotoUrl,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}