import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../../core/api/Api_Service/Live_Location/live_location.dart';

class LiveLocationController extends GetxController {

  Timer? _timer;
  final Battery _battery = Battery();

  @override
  void onInit() {
    super.onInit();
    startLocationTracking();
  }

  Future<void> startLocationTracking() async {
    await _checkPermission();

    // First Call Immediately
    await _sendLocation();

    // Call every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _sendLocation();
    });
  }

  Future<void> _sendLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      int batteryLevel = await _battery.batteryLevel;

      await LiveLocationService.sendLiveLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        heading: position.heading,
        speed: position.speed,
        battery: batteryLevel,
        source: "gps",
      );

    } catch (e) {
      print("LOCATION FETCH ERROR: $e");
    }
  }

  Future<void> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Permission Required", "Location permission required");
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}