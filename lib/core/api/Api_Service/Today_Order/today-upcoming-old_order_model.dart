// import 'address_model.dart';
//
// class TodayOrderModel {
//   final int orderId;
//   final bool isPaid;
//   final String serviceDate;
//   final String slotTime;
//   final double totalAmount;
//   final List<String> services;
//   final AddressModel? address;
//
//   TodayOrderModel({
//     required this.orderId,
//     required this.isPaid,
//     required this.serviceDate,
//     required this.slotTime,
//     required this.totalAmount,
//     required this.services,
//     this.address,
//   });
//
//   factory TodayOrderModel.fromJson(Map<String, dynamic> json) {
//     return TodayOrderModel(
//       orderId: json['order_id'] ?? 0,
//       isPaid: json['is_paid'] ?? false,
//       serviceDate: json['service_date'] ?? '',
//       slotTime: json['slot_time'] ?? '',
//       totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
//       services: json['services'] != null
//           ? List<String>.from(json['services'])
//           : [],
//       address: json['address'] != null
//           ? AddressModel.fromJson(json['address'])
//           : null,
//     );
//   }
// }


import 'address_model.dart';

/// ================= CONTACT MODEL =================
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

  /// Helper
  bool get canCall => phone != null && phone!.isNotEmpty;

  String get displayText =>
      phone ?? message ?? "Phone number not available";
}

/// ================= TODAY ORDER MODEL =================

class OrderModel {
  final int orderId;
  final bool isPaid;
  final String serviceDate;
  final String slotTime;
  final double totalAmount;
  final List<String> services;
  final AddressModel? address;
  final ContactModel? contact;

  OrderModel({
    required this.orderId,
    required this.isPaid,
    required this.serviceDate,
    required this.slotTime,
    required this.totalAmount,
    required this.services,
    this.address,
    this.contact,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['order_id'] ?? 0,
      isPaid: json['is_paid'] ?? false,
      serviceDate: json['service_date'] ?? '',
      slotTime: json['slot_time'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
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
