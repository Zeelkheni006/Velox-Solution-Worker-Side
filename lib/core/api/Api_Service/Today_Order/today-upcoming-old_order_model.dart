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
  final int userId;
  final String serviceDate;
  final String slotTime;
  final double totalAmount;
  final String paymentStatus;
  final String orderStatus;
  final String bookingCode;
  final List<String> services;
  final AddressModel? address;
  final ContactModel? contact;
  final List<ServiceDetailModel> serviceDetails;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.serviceDate,
    required this.slotTime,
    required this.totalAmount,
    required this.paymentStatus,
    required this.orderStatus,
    required this.bookingCode,
    required this.services,
    this.address,
    this.contact,
    this.serviceDetails = const [],
  });

  OrderModel copyWith({
    double? totalAmount,
  }) {
    return OrderModel(
      orderId: orderId,
      userId: userId,
      serviceDate: serviceDate,
      slotTime: slotTime,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus,
      orderStatus: orderStatus,
      bookingCode: bookingCode,
      services: services,
      address: address,
      contact: contact,
      serviceDetails: serviceDetails,
    );
  }

  bool get isPaid => paymentStatus == 'paid';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] ?? 0,
      userId: json['user_id'] as int? ?? 0,
      serviceDate: json['service_date'] ?? '',
      slotTime: json['slot_time'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] ?? 'unpaid',
      bookingCode: json['booking_code'] ?? '',
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
        serviceDetails: (json['service_details'] as List<dynamic>?)
              ?.map((e) => ServiceDetailModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ServiceDetailModel {
  final int serviceId;
  final String serviceName;
  final int quantity;

  const ServiceDetailModel({
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
  });

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailModel(
      serviceId: json['service_id'] as int? ?? 0,
      serviceName: json['service_name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}
