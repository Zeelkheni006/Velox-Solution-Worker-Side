class AddressModel {
  final String? city;
  final String? state;
  final String? country;
  final String? floor;
  final String? formattedAddress;
  final String? houseNumber;
  final String? instructions;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final String? navigationUrl;
  final String? postalCode;
  final String? message;

  AddressModel({
    this.city,
    this.state,
    this.country,
    this.floor,
    this.formattedAddress,
    this.houseNumber,
    this.instructions,
    this.landmark,
    this.latitude,
    this.longitude,
    this.navigationUrl,
    this.postalCode,
    this.message,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      city: json['city'],
      state: json['state'],
      country: json['country'],
      floor: json['floor'],
      formattedAddress: json['formatted_address'],
      houseNumber: json['house_number'],
      instructions: json['instructions'],
      landmark: json['landmark'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      navigationUrl: json['navigation_url'],
      postalCode: json['postal_code'],
      message: json['message'],
    );
  }

  /// Helpers
  bool get canNavigate => latitude != null && longitude != null;

  String get displayText =>
      formattedAddress ?? message ?? "Address not available";
}
