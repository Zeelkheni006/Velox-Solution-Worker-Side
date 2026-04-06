import 'address_model.dart';

class ContactModel {
  final String? phone;
  final String? message;

  ContactModel({
    this.phone,
    this.message,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      phone: json['phone'],
      message: json['message'],
    );
  }

  bool get canCall => phone != null && phone!.isNotEmpty;

  String get displayText =>
      phone ?? message ?? "Phone number not available";
}

class OrderModel {
  final int orderId;
  final String serviceDate;
  final String slotTime;
  final double totalAmount;
  final String paymentStatus;
  final String orderStatus;
  final List<String> services;
  final AddressModel? address;
  final ContactModel? contact;

  // ✅ THIS WAS MISSING
  OrderModel({
    required this.orderId,
    required this.serviceDate,
    required this.slotTime,
    required this.totalAmount,
    required this.paymentStatus,
    required this.orderStatus,
    required this.services,
    this.address,
    this.contact,
  });

  // ✅ copyWith
  OrderModel copyWith({
    double? totalAmount,
  }) {
    return OrderModel(
      orderId: orderId,
      serviceDate: serviceDate,
      slotTime: slotTime,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus,
      orderStatus: orderStatus,
      services: services,
      address: address,
      contact: contact,
    );
  }

  bool get isPaid => paymentStatus == 'paid';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] ?? 0,
      serviceDate: json['service_date'] ?? '',
      slotTime: json['slot_time'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] ?? 'unpaid',
      orderStatus: json['order_status'] ?? '',
      services: json['services'] != null
          ? List<String>.from(json['services'])
          : [],
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'])
          : null,
      contact: json['contact'] != null
          ? ContactModel.fromJson(json['contact'])
          : null,
    );
  }
}
