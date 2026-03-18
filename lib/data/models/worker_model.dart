// lib/data/models/worker_model.dart

class WorkerModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String serviceSpecialty; // e.g., 'AC Repair', 'Beauty Salon'
  final String? profilePhotoUrl;
  final double rating;
  final int completedJobs;
  final bool isOnline; // For immediate status toggle
  final double latitude;
  final double longitude;
  final Map<String, List<String>> availabilitySlots; // { 'Monday': ['09:00', '17:00'], ...}

  WorkerModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.serviceSpecialty,
    this.profilePhotoUrl,
    this.rating = 0.0,
    this.completedJobs = 0,
    this.isOnline = false,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.availabilitySlots = const {},
  });

  // Factory method to create a WorkerModel from a JSON map (e.g., from an API)
  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      serviceSpecialty: json['serviceSpecialty'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      rating: (json['rating'] as num).toDouble(),
      completedJobs: json['completedJobs'] as int,
      isOnline: json['isOnline'] as bool,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      availabilitySlots: (json['availabilitySlots'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, List<String>.from(value))),
    );
  }

  // Method to convert the WorkerModel to a JSON map (e.g., for sending to an API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'serviceSpecialty': serviceSpecialty,
      'profilePhotoUrl': profilePhotoUrl,
      'rating': rating,
      'completedJobs': completedJobs,
      'isOnline': isOnline,
      'latitude': latitude,
      'longitude': longitude,
      'availabilitySlots': availabilitySlots,
    };
  }
}