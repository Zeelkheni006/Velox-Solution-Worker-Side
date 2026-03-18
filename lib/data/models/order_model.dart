// lib/data/models/order_model.dart

class OrderModel {
  final String id;
  final String serviceName;
  final String customerName;
  final String customerPhone;
  final String status; // e.g., 'NEW', 'ACCEPTED', 'TRAVELING', 'IN_SERVICE', 'COMPLETED'

  // Location and Timing
  final DateTime scheduledTime;
  final double customerLat;
  final double customerLon;
  final String customerAddress; // The full address string
  final bool isAddressRevealed; // State for the 30-minute rule
  final DateTime revealTime; // The exact time the address is revealed

  // Payment Details
  final String paymentStatus; // e.g., 'PENDING', 'PAID_ONLINE', 'CASH_COLLECT'
  final double totalAmount;

  // Verification Details
  final String? startOtp; // OTP provided by user to start service
  final String? completionPhotoUrl; // URL for the photo uploaded by worker
  final String? cancellationReason;

  OrderModel({
    required this.id,
    required this.serviceName,
    required this.customerName,
    required this.customerPhone,
    required this.status,
    required this.scheduledTime,
    required this.customerLat,
    required this.customerLon,
    required this.customerAddress,
    required this.totalAmount,
    this.paymentStatus = 'PENDING',
    this.startOtp,
    this.completionPhotoUrl,
    this.cancellationReason,
  }) :
  // Calculate the address reveal time (30 minutes before scheduled time)
        revealTime = scheduledTime.subtract(const Duration(minutes: 30)),
  // Determine initial reveal status
        isAddressRevealed = DateTime.now().isAfter(scheduledTime.subtract(const Duration(minutes: 30)));


  // Helper getter to determine if the location is currently accessible
  bool get canRevealAddress {
    return DateTime.now().isAfter(revealTime);
  }

// Factory and toJson methods (omitted for brevity, but crucial for API integration)
// ...
}

// Example usage of the calculated reveal time logic:
/*
void checkRevealTime(OrderModel order) {
  if (order.canRevealAddress) {
    print('Address is: ${order.customerAddress}');
  } else {
    print('Address will be revealed at: ${order.revealTime.toString()}');
  }
}
*/