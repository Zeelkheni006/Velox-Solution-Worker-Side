import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/custom_container.dart';

class NavigationPage extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;
  final String destinationName;

  const NavigationPage({
    super.key,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  // ── Google Maps ───────────────────────────────────────────────────────────
  final Completer<GoogleMapController> _mapCompleter = Completer();
  GoogleMapController? _mapController;

  // ── Location ──────────────────────────────────────────────────────────────
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSub;
  bool _locationLoading = true;
  String? _locationError;

  // ── Route ─────────────────────────────────────────────────────────────────
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  bool _routeLoading = false;
  String? _routeError;

  // ── Navigation Info ───────────────────────────────────────────────────────
  double _distanceKm = 0;
  int _etaMinutes = 0;
  String _nextInstruction = "Calculating route…";
  List<Map<String, dynamic>> _steps = [];
  int _currentStepIndex = 0;
  bool _isFollowingUser = true;

  // Google Maps API key
  static const _apiKey = 'AIzaSyAiZEpiF_zu6RDeg8yFF8ydOUiHiXQA4DA';

  // ── Google Maps Style (Uber/navigation dark style) ────────────────────────
  // Use null for default Google Maps look
  // Or paste a JSON style from https://mapstyle.withgoogle.com/
  static const String? _mapStyle = null; // null = default Google Maps

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> _initLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          _setError("Location permission denied.");
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        _setError("Please enable location in Settings.");
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = pos;
        _locationLoading = false;
      });

      _setMarkers(pos);
      await _fetchGoogleRoute(pos.latitude, pos.longitude);
      _startTracking();
    } catch (e) {
      _setError("Could not get location: $e");
    }
  }

  void _setError(String msg) =>
      setState(() { _locationError = msg; _locationLoading = false; });

  void _startTracking() {
    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(_onLocationUpdate);
  }

  void _onLocationUpdate(Position pos) async {
    setState(() => _currentPosition = pos);
    _updateNavInfo(pos);

    if (!_isFollowingUser || _mapController == null) return;

    // Smooth camera follow with heading
    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(pos.latitude, pos.longitude),
          zoom: 17,
          tilt: 50,
          bearing: pos.heading,
        ),
      ),
    );
  }

  // ── Markers ───────────────────────────────────────────────────────────────

  void _setMarkers(Position pos) {
    setState(() {
      _markers.clear();

      // Destination marker
      _markers.add(Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.destinationLat, widget.destinationLng),
        infoWindow: InfoWindow(title: widget.destinationName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    });
  }

  // ── Google Directions API Route ───────────────────────────────────────────

  Future<void> _fetchGoogleRoute(double fromLat, double fromLng) async {
    setState(() { _routeLoading = true; _routeError = null; });

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=$fromLat,$fromLng'
            '&destination=${widget.destinationLat},${widget.destinationLng}'
            '&mode=driving'
            '&language=en'
            '&key=$_apiKey',
      );

      final res = await http.get(url).timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body);

      if (data['status'] == 'OK') {
        final route = data['routes'][0];
        final leg = route['legs'][0];

        // Decode polyline
        final encoded = route['overview_polyline']['points'];
        final points = _decodePolyline(encoded);

        // Parse steps
        final steps = <Map<String, dynamic>>[];
        for (final step in leg['steps'] as List) {
          steps.add({
            'instruction': _stripHtml(step['html_instructions'] ?? ''),
            'distance_m': (step['distance']['value'] as num).toDouble(),
            'lat': (step['end_location']['lat'] as num).toDouble(),
            'lng': (step['end_location']['lng'] as num).toDouble(),
          });
        }

        final distM = (leg['distance']['value'] as num).toDouble();
        final durS = (leg['duration']['value'] as num).toDouble();

        setState(() {
          _distanceKm = distM / 1000;
          _etaMinutes = (durS / 60).round();
          _steps = steps;
          _nextInstruction = steps.isNotEmpty
              ? steps[0]['instruction']
              : "Head to destination";
          _routeLoading = false;

          // Draw blue route polyline
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: points,
            color: const Color(0xFF1A73E8), // Google Maps blue
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ));

          // Lighter outline polyline
          _polylines.add(Polyline(
            polylineId: const PolylineId('route-outline'),
            points: points,
            color: Colors.white.withOpacity(0.4),
            width: 10,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
            zIndex: -1,
          ));
        });

        // Fit camera to route
        _fitRoute(points);
      } else {
        throw Exception(data['status']);
      }
    } catch (e) {
      debugPrint('Route error: $e');
      // Fallback: straight line
      setState(() {
        _routeError = "Could not load route. Showing straight line.";
        _routeLoading = false;
        _distanceKm = _haversineKm(
          fromLat, fromLng,
          widget.destinationLat, widget.destinationLng,
        );
        _etaMinutes = (_distanceKm / 0.5).round();
        _nextInstruction = "Head towards destination";

        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(fromLat, fromLng),
            LatLng(widget.destinationLat, widget.destinationLng),
          ],
          color: const Color(0xFF1A73E8),
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ));
      });
    }
  }

  // ── Fit camera to full route ──────────────────────────────────────────────

  void _fitRoute(List<LatLng> points) async {
    if (_mapController == null || points.isEmpty) return;
    final bounds = _boundsFromLatLngList(points);
    await Future.delayed(const Duration(milliseconds: 300));
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double minLat = list.first.latitude;
    double maxLat = list.first.latitude;
    double minLng = list.first.longitude;
    double maxLng = list.first.longitude;
    for (final p in list) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // ── Google Polyline Decoder ───────────────────────────────────────────────

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0, lng = 0;

    while (index < encoded.length) {
      int shift = 0, result = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0; result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  // ── Strip HTML tags from Google step instructions ─────────────────────────

  String _stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll('  ', ' ').trim();

  // ── Navigation info update ────────────────────────────────────────────────

  void _updateNavInfo(Position pos) {
    setState(() {
      _distanceKm = _haversineKm(
        pos.latitude, pos.longitude,
        widget.destinationLat, widget.destinationLng,
      );
      _etaMinutes = _distanceKm < 0.1 ? 0 : (_distanceKm / 0.5).round();

      if (_steps.isNotEmpty && _currentStepIndex < _steps.length - 1) {
        final step = _steps[_currentStepIndex];
        if (_haversineKm(pos.latitude, pos.longitude,
            step['lat'], step['lng']) < 0.04) {
          _currentStepIndex++;
          _nextInstruction = _steps[_currentStepIndex]['instruction'];
        }
      }
    });
  }

  double _haversineKm(double la1, double lo1, double la2, double lo2) {
    const R = 6371.0;
    final dLat = _rad(la2 - la1), dLng = _rad(lo2 - lo1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(la1)) * math.cos(_rad(la2)) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _rad(double d) => d * math.pi / 180;

  String get _distanceText => _distanceKm < 1
      ? '${(_distanceKm * 1000).round()} m'
      : '${_distanceKm.toStringAsFixed(1)} km';

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ──────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : LatLng(widget.destinationLat, widget.destinationLng),
              zoom: 14,
              tilt: 30,
            ),
            myLocationEnabled: true,          // Blue dot
            myLocationButtonEnabled: false,   // We use custom button
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            trafficEnabled: true,             // Live traffic layer!
            buildingsEnabled: true,           // 3D buildings
            style: _mapStyle,
            polylines: _polylines,
            markers: _markers,
            onMapCreated: (controller) async {
              _mapCompleter.complete(controller);
              _mapController = controller;
              if (_mapStyle != null) {
                await controller.setMapStyle(_mapStyle);
              }
            },
            onCameraMoveStarted: () {
              if (_isFollowingUser) {
                setState(() => _isFollowingUser = false);
              }
            },
          ),

          // ── Top bar ─────────────────────────────────────────────────────
          _buildTopBar(context),

          // ── Loading / Error ──────────────────────────────────────────────
          if (_locationLoading) _buildLoader(context),
          if (_locationError != null) _buildError(context),

          // ── Bottom panel ─────────────────────────────────────────────────
          if (!_locationLoading && _locationError == null)
            _buildBottomPanel(context),

          // ── Re-center button ─────────────────────────────────────────────
          if (!_locationLoading && _locationError == null && !_isFollowingUser)
            _buildRecenterBtn(context),
        ],
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(rs(context, 12)),
        child: Row(children: [
          GestureDetector(
            onTap: Get.back,
            child: _glassBox(
              context,
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: rs(context, 18), color: Colors.black87),
            ),
          ),
          SizedBox(width: rs(context, 10)),
          Expanded(
            child: _glassBox(
              context,
              padding: EdgeInsets.symmetric(
                  horizontal: rs(context, 14), vertical: rs(context, 11)),
              child: Row(children: [
                Icon(Icons.location_on_rounded,
                    color: Colors.red, size: rs(context, 18)),
                SizedBox(width: rs(context, 8)),
                Expanded(
                  child: Text(
                    widget.destinationName,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _glassBox(BuildContext context,
      {required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? EdgeInsets.all(rs(context, 10)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: child,
    );
  }

  // ── Loader ────────────────────────────────────────────────────────────────

  Widget _buildLoader(BuildContext context) => Center(
    child: Container(
      padding: EdgeInsets.all(rs(context, 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 20)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 20)
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: rs(context, 12)),
        Text("Getting your location…",
            style: AppTextStyles.bodyMedium(context)),
      ]),
    ),
  );

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError(BuildContext context) => Center(
    child: Container(
      margin: EdgeInsets.all(rs(context, 24)),
      padding: EdgeInsets.all(rs(context, 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 20)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.location_off_rounded,
            color: Colors.red, size: rs(context, 40)),
        SizedBox(height: rs(context, 12)),
        Text(_locationError ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(context)),
        SizedBox(height: rs(context, 16)),
        GestureDetector(
          onTap: () {
            setState(() {
              _locationError = null;
              _locationLoading = true;
            });
            _initLocation();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: rs(context, 20), vertical: rs(context, 10)),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(rs(context, 12)),
            ),
            child: Text('Retry',
                style: AppTextStyles.buttonMedium(context)
                    .copyWith(color: Colors.white)),
          ),
        ),
      ]),
    ),
  );

  // ── Bottom Panel ──────────────────────────────────────────────────────────

  Widget _buildBottomPanel(BuildContext context) {
    final arrived = _distanceKm < 0.05 && !_routeLoading;

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          rs(context, 16), rs(context, 14),
          rs(context, 16), rs(context, 28),
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(rs(context, 28))),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4))
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: rs(context, 14)),

          if (!arrived) ...[
            // ── Next instruction card ──────────────────────────────────
            Container(
              padding: EdgeInsets.all(rs(context, 14)),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(rs(context, 16)),
                border: Border.all(color: AppColors.primary.withOpacity(0.18)),
              ),
              child: Row(children: [
                Container(
                  padding: EdgeInsets.all(rs(context, 10)),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(rs(context, 12)),
                  ),
                  child: Icon(Icons.navigation_rounded,
                      color: Colors.white, size: rs(context, 20)),
                ),
                SizedBox(width: rs(context, 12)),
                Expanded(
                  child: Text(
                    _routeLoading ? "Calculating route…" : _nextInstruction,
                    style: AppTextStyles.bodyMedium(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (_routeLoading)
                  SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
              ]),
            ),
            SizedBox(height: rs(context, 12)),

            // ── Distance & ETA ─────────────────────────────────────────
            Row(children: [
              Expanded(child: _statTile(
                context,
                icon: Icons.straighten_rounded,
                label: 'Distance',
                value: _distanceText,
                color: AppColors.primary,
              )),
              SizedBox(width: rs(context, 12)),
              Expanded(child: _statTile(
                context,
                icon: Icons.timer_rounded,
                label: 'ETA',
                value: _etaMinutes < 1 ? '< 1 min' : '$_etaMinutes min',
                color: AppColors.secondary,
              )),
            ]),
          ],

          // ── Arrived ────────────────────────────────────────────────────
          if (arrived)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(rs(context, 16)),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(rs(context, 16)),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: rs(context, 26)),
                SizedBox(width: rs(context, 10)),
                Text("You have arrived!",
                    style: AppTextStyles.bodyLarge(context).copyWith(
                        color: Colors.green, fontWeight: FontWeight.bold)),
              ]),
            ),

          // ── Offline warning ────────────────────────────────────────────
          if (_routeError != null)
            Padding(
              padding: EdgeInsets.only(top: rs(context, 8)),
              child: Row(children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: rs(context, 14)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(_routeError!,
                      style: AppTextStyles.bodySmall(context)
                          .copyWith(color: Colors.orange)),
                ),
              ]),
            ),
        ]),
      ),
    );
  }

  Widget _statTile(BuildContext context,
      {required IconData icon,
        required String label,
        required String value,
        required Color color}) {
    return Container(
      padding: EdgeInsets.all(rs(context, 12)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(rs(context, 14)),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: rs(context, 20)),
        SizedBox(width: rs(context, 8)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: AppTextStyles.bodySmall(context)
                  .copyWith(color: AppColors.textSecondary)),
          Text(value,
              style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.bold, color: color)),
        ]),
      ]),
    );
  }

  // ── Re-center Button ──────────────────────────────────────────────────────

  Widget _buildRecenterBtn(BuildContext context) => Positioned(
    right: rs(context, 16),
    bottom: rs(context, 210),
    child: GestureDetector(
      onTap: () async {
        if (_currentPosition == null) return;
        setState(() => _isFollowingUser = true);
        await _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
                _currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 17,
            tilt: 50,
            bearing: _currentPosition!.heading,
          )),
        );
      },
      child: Container(
        padding: EdgeInsets.all(rs(context, 12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rs(context, 14)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Icon(Icons.my_location_rounded,
            color: AppColors.primary, size: rs(context, 24)),
      ),
    ),
  );

  @override
  void dispose() {
    _locationSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}