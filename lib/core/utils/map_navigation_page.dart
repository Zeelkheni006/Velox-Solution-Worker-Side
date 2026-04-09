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
import '../App_Safety/app_safety.dart';

// ── Location State Enum ───────────────────────────────────────────────────────
//
//  loading       = initial / retrying (show spinner)
//  gpsOff        = device GPS/Location Service is disabled
//  denied        = user tapped Deny once  (can re-request via OS dialog)
//  deniedForever = user tapped "Never ask again" (only App Settings can fix)
//  unknown       = unexpected exception

enum _LocationState { loading, gpsOff, denied, deniedForever, unknown }

// ── Route Model ───────────────────────────────────────────────────────────────

class RouteOption {
  final int index;
  final String label;       // "Fastest", "Alternate 1", "Alternate 2"
  final String summary;     // via Highway / via City Center, etc.
  final double distanceKm;
  final int durationMinutes;
  final List<LatLng> polylinePoints;
  final List<Map<String, dynamic>> steps;
  final Color color;
  final bool isFastest;

  const RouteOption({
    required this.index,
    required this.label,
    required this.summary,
    required this.distanceKm,
    required this.durationMinutes,
    required this.polylinePoints,
    required this.steps,
    required this.color,
    required this.isFastest,
  });
}

// ── Page ──────────────────────────────────────────────────────────────────────

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

class _NavigationPageState extends State<NavigationPage>
    with TickerProviderStateMixin {
  // ── Map ───────────────────────────────────────────────────────────────────
  final Completer<GoogleMapController> _mapCompleter = Completer();
  GoogleMapController? _mapController;

  // ── Location ──────────────────────────────────────────────────────────────
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSub;
  bool _locationLoading = true;
  String? _locationError;

  // ── Routes ────────────────────────────────────────────────────────────────
  List<RouteOption> _routes = [];
  int _selectedRouteIndex = 0;       // Which route is selected
  bool _routeLoading = false;
  String? _routeError;
  bool _navigationStarted = false;   // Route-selection phase vs navigation phase

  // ── Active Navigation ─────────────────────────────────────────────────────
  double _distanceKm = 0;
  int _etaMinutes = 0;
  String _nextInstruction = "Calculating route…";
  int _currentStepIndex = 0;
  bool _isFollowingUser = true;

  // ── Map overlays ──────────────────────────────────────────────────────────
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  // ── Route colours ─────────────────────────────────────────────────────────
  static const List<Color> _routeColors = [
    Color(0xFF1A73E8), // Google blue  — fastest / selected
    Color(0xFF34A853), // Google green — alternate 1
    Color(0xFFFF6D00), // Orange       — alternate 2
  ];

  static const Color _unselectedRouteColor = Color(0xFF9E9E9E);

  // ── API ───────────────────────────────────────────────────────────────────
  static const _apiKey = 'AIzaSyAiZEpiF_zu6RDeg8yFF8ydOUiHiXQA4DA';

  // ── Route-sheet animation ─────────────────────────────────────────────────
  late AnimationController _sheetAnimCtrl;
  late Animation<double> _sheetAnim;

  @override
  void initState() {
    super.initState();
    _sheetAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _sheetAnim = CurvedAnimation(
      parent: _sheetAnimCtrl,
      curve: Curves.easeOutCubic,
    );
    _initLocation();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _mapController?.dispose();
    _sheetAnimCtrl.dispose();
    super.dispose();
  }

  // ── Location state ─────────────────────────────────────────────────────────
  //  Tracks exactly WHY we are in error screen → drives different UI per case.
  _LocationState _locState = _LocationState.loading;

  Future<void> _initLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError   = null;
      _locState        = _LocationState.loading;
    });

    try {
      // ── Step 1: Is GPS / Location Service ON? ─────────────────────────────
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        _setLocError(
          _LocationState.gpsOff,
          'Turn on Location (GPS)',
          'Your device GPS is switched off.\nEnable it in phone Settings to use navigation.',
        );
        return;
      }

      // ── Step 2: Check app-level permission ────────────────────────────────
      LocationPermission perm = await Geolocator.checkPermission();

      // Already permanently blocked — cannot show OS dialog
      if (perm == LocationPermission.deniedForever) {
        _setLocError(
          _LocationState.deniedForever,
          'Location access blocked',
          'You permanently denied location for this app.\nOpen App Settings → Permissions → Location and set it to "Allow".',
        );
        return;
      }

      // Not yet granted — show OS dialog
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();

        if (perm == LocationPermission.deniedForever) {
          _setLocError(
            _LocationState.deniedForever,
            'Location access blocked',
            'You permanently denied location for this app.\nOpen App Settings → Permissions → Location and set it to "Allow".',
          );
          return;
        }

        if (perm == LocationPermission.denied) {
          // Tapped "Deny" but NOT "Never ask again" — retry still works
          _setLocError(
            _LocationState.denied,
            'Location permission denied',
            'Navigation needs your location.\nTap "Allow location" to try again.',
          );
          return;
        }
      }

      // ── Step 3: Permission granted — get actual position ──────────────────
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = pos;
        _locationLoading = false;
        _locState        = _LocationState.loading; // clear any previous error
      });

      _setMarkers(pos);
      await _fetchAllRoutes(pos.latitude, pos.longitude);
      _sheetAnimCtrl.forward();

    } catch (e) {
      _setLocError(
        _LocationState.unknown,
        'Something went wrong',
        'Could not get your location.\nMake sure GPS and location permission are enabled.',
      );
    }
  }

  void _setLocError(_LocationState state, String title, String body) {
    setState(() {
      _locState        = state;
      _locationError   = body;   // body is shown as subtitle in error widget
      _locationLoading = false;
    });
  }

  // Used by _fetchAllRoutes fallback — keep for compatibility
  void _setError(String msg) =>
      setState(() { _locationError = msg; _locationLoading = false; });

  // ── Markers ───────────────────────────────────────────────────────────────

  void _setMarkers(Position pos) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(widget.destinationLat, widget.destinationLng),
          infoWindow: InfoWindow(title: widget.destinationName),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });
  }

  // ── Fetch ALL routes from Google Directions API (alternatives=true) ────────

  Future<void> _fetchAllRoutes(double fromLat, double fromLng) async {
    setState(() { _routeLoading = true; _routeError = null; });

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=$fromLat,$fromLng'
            '&destination=${widget.destinationLat},${widget.destinationLng}'
            '&mode=driving'
            '&alternatives=true'       // ← KEY: request all alternative routes
            '&language=en'
            '&key=$_apiKey',
      );

      final res = await http.get(url).timeout(const Duration(seconds: 20));
      final data = jsonDecode(res.body);

      if (data['status'] != 'OK') throw Exception(data['status']);

      final rawRoutes = data['routes'] as List;
      final List<RouteOption> options = [];

      // Google returns routes sorted best-first
      for (int i = 0; i < rawRoutes.length; i++) {
        final r = rawRoutes[i];
        final leg = r['legs'][0];

        final steps = <Map<String, dynamic>>[];
        for (final s in leg['steps'] as List) {
          steps.add({
            'instruction': _stripHtml(s['html_instructions'] ?? ''),
            'distance_m': (s['distance']['value'] as num).toDouble(),
            'lat': (s['end_location']['lat'] as num).toDouble(),
            'lng': (s['end_location']['lng'] as num).toDouble(),
          });
        }

        final distM   = (leg['distance']['value'] as num).toDouble();
        final durSec  = (leg['duration']['value'] as num).toDouble();
        final summary = r['summary'] as String? ?? 'Route ${i + 1}';

        options.add(RouteOption(
          index: i,
          label: i == 0 ? 'Fastest route' : 'Alternate ${i}',
          summary: 'via $summary',
          distanceKm: distM / 1000,
          durationMinutes: (durSec / 60).round(),
          polylinePoints: _decodePolyline(r['overview_polyline']['points']),
          steps: steps,
          color: i < _routeColors.length
              ? _routeColors[i]
              : _routeColors.last,
          isFastest: i == 0,
        ));
      }

      setState(() {
        _routes = options;
        _selectedRouteIndex = 0;
        _routeLoading = false;
      });

      _rebuildPolylines();
      _fitAllRoutes();

    } catch (e) {
      logPrint('Route fetch error: $e');
      _buildFallbackRoute(fromLat, fromLng);
    }
  }

  // ── Rebuild polylines based on selection ──────────────────────────────────

  void _rebuildPolylines() {
    final polys = <Polyline>{};

    for (final route in _routes) {
      final isSelected = route.index == _selectedRouteIndex;
      final color = isSelected ? route.color : _unselectedRouteColor;

      // Outline for selected route
      if (isSelected) {
        polys.add(Polyline(
          polylineId: PolylineId('route-outline-${route.index}'),
          points: route.polylinePoints,
          color: Colors.white.withOpacity(0.5),
          width: 12,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          zIndex: 0,
        ));
      }

      polys.add(Polyline(
        polylineId: PolylineId('route-${route.index}'),
        points: route.polylinePoints,
        color: color,
        width: isSelected ? 7 : 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        zIndex: isSelected ? 2 : 1,
        // Unselected routes are dashed
        patterns: isSelected
            ? []
            : [PatternItem.dash(15), PatternItem.gap(8)],
        consumeTapEvents: !isSelected,
        onTap: isSelected ? null : () => _selectRoute(route.index),
      ));
    }

    setState(() => _polylines = polys);
  }

  // ── Select a route ────────────────────────────────────────────────────────

  void _selectRoute(int index) {
    if (index == _selectedRouteIndex) return;
    setState(() => _selectedRouteIndex = index);
    _rebuildPolylines();
    _fitAllRoutes();
  }

  // ── Start navigation with selected route ──────────────────────────────────

  void _startNavigation() {
    final route = _routes[_selectedRouteIndex];
    setState(() {
      _navigationStarted = true;
      _distanceKm = route.distanceKm;
      _etaMinutes = route.durationMinutes;
      _nextInstruction = route.steps.isNotEmpty
          ? route.steps[0]['instruction']
          : "Head to destination";
      _currentStepIndex = 0;
    });
    _startTracking();

    // Animate to user with tilt
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(
              _currentPosition!.latitude, _currentPosition!.longitude),
          zoom: 17,
          tilt: 50,
          bearing: _currentPosition!.heading,
        )),
      );
    }
  }

  // ── Live tracking ─────────────────────────────────────────────────────────

  void _startTracking() {
    _locationSub?.cancel();
    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(_onLocationUpdate);
  }

  void _onLocationUpdate(Position pos) {
    setState(() => _currentPosition = pos);
    _updateNavInfo(pos);
    if (!_isFollowingUser || _mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 17,
        tilt: 50,
        bearing: pos.heading,
      )),
    );
  }

  void _updateNavInfo(Position pos) {
    final route = _selectedRoute;
    if (route == null) return;

    setState(() {
      _distanceKm = _haversineKm(
        pos.latitude, pos.longitude,
        widget.destinationLat, widget.destinationLng,
      );
      _etaMinutes = _distanceKm < 0.1 ? 0 : (_distanceKm / 0.5).round();

      final steps = route.steps;
      if (steps.isNotEmpty && _currentStepIndex < steps.length - 1) {
        final step = steps[_currentStepIndex];
        if (_haversineKm(
            pos.latitude, pos.longitude, step['lat'], step['lng']) < 0.04) {
          _currentStepIndex++;
          _nextInstruction = steps[_currentStepIndex]['instruction'];
        }
      }
    });
  }

  // ── Camera helpers ────────────────────────────────────────────────────────

  void _fitAllRoutes() async {
    if (_mapController == null || _routes.isEmpty) return;
    final allPoints = _routes.expand((r) => r.polylinePoints).toList();
    if (allPoints.isEmpty) return;
    final bounds = _boundsFromList(allPoints);
    await Future.delayed(const Duration(milliseconds: 300));
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 90));
  }

  LatLngBounds _boundsFromList(List<LatLng> pts) {
    double minLat = pts.first.latitude, maxLat = pts.first.latitude;
    double minLng = pts.first.longitude, maxLng = pts.first.longitude;
    for (final p in pts) {
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

  // ── Fallback (straight line) ──────────────────────────────────────────────

  void _buildFallbackRoute(double fromLat, double fromLng) {
    final km = _haversineKm(
        fromLat, fromLng, widget.destinationLat, widget.destinationLng);
    final fallback = RouteOption(
      index: 0,
      label: 'Direct route',
      summary: 'Straight line (no internet)',
      distanceKm: km,
      durationMinutes: (km / 0.5).round(),
      polylinePoints: [
        LatLng(fromLat, fromLng),
        LatLng(widget.destinationLat, widget.destinationLng),
      ],
      steps: [],
      color: _routeColors[0],
      isFastest: true,
    );
    setState(() {
      _routes = [fallback];
      _selectedRouteIndex = 0;
      _routeLoading = false;
      _routeError = "Could not load routes. Showing straight line.";
    });
    _rebuildPolylines();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  RouteOption? get _selectedRoute => _routes.isEmpty
      ? null
      : _routes[_selectedRouteIndex.clamp(0, _routes.length - 1)];

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> pts = [];
    int i = 0, lat = 0, lng = 0;
    while (i < encoded.length) {
      int shift = 0, result = 0, b;
      do { b = encoded.codeUnitAt(i++) - 63; result |= (b & 0x1f) << shift; shift += 5; } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      shift = 0; result = 0;
      do { b = encoded.codeUnitAt(i++) - 63; result |= (b & 0x1f) << shift; shift += 5; } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      pts.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return pts;
  }

  String _stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll('  ', ' ').trim();

  double _haversineKm(double la1, double lo1, double la2, double lo2) {
    const R = 6371.0;
    final dLat = _rad(la2 - la1), dLng = _rad(lo2 - lo1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(la1)) * math.cos(_rad(la2)) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _rad(double d) => d * math.pi / 180;

  String _fmtDist(double km) => km < 1
      ? '${(km * 1000).round()} m'
      : '${km.toStringAsFixed(1)} km';

  String _fmtDur(int min) {
    if (min < 60) return '$min min';
    return '${min ~/ 60}h ${min % 60}m';
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : LatLng(widget.destinationLat, widget.destinationLng),
              zoom: 13,
              tilt: 20,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            trafficEnabled: true,
            buildingsEnabled: true,
            polylines: _polylines,
            markers: _markers,
            onMapCreated: (c) {
              _mapCompleter.complete(c);
              _mapController = c;
            },
            onCameraMoveStarted: () {
              if (_isFollowingUser) setState(() => _isFollowingUser = false);
            },
          ),

          // ── Top bar ──────────────────────────────────────────────────────
          _buildTopBar(context),

          // ── Loaders / Errors ─────────────────────────────────────────────
          if (_locationLoading) _buildLoader(context),
          if (_locationError != null) _buildError(context),

          // ── Route Selection Sheet (before navigation starts) ──────────────
          if (!_locationLoading && _locationError == null && !_navigationStarted)
            _buildRouteSelectionSheet(context),

          // ── Navigation Bottom Panel (after navigation starts) ─────────────
          if (_navigationStarted)
            _buildNavigationPanel(context),

          // ── Re-center FAB ─────────────────────────────────────────────────
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
                if (_routeLoading)
                  SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
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
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 10, offset: const Offset(0, 3),
        )],
      ),
      child: child,
    );
  }

  // ── Route Selection Sheet ─────────────────────────────────────────────────

  Widget _buildRouteSelectionSheet(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: AnimatedBuilder(
        animation: _sheetAnim,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, (1 - _sheetAnim.value) * 300),
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(rs(context, 28))),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24, offset: const Offset(0, -6),
            )],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: EdgeInsets.only(top: rs(context, 12)),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: rs(context, 10)),

              // Title row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: rs(context, 20)),
                child: Row(
                  children: [
                    Icon(Icons.alt_route_rounded,
                        color: AppColors.primary, size: rs(context, 22)),
                    SizedBox(width: rs(context, 8)),
                    Text(
                      _routes.isEmpty
                          ? 'Finding routes…'
                          : '${_routes.length} route${_routes.length > 1 ? 's' : ''} found',
                      style: AppTextStyles.bodyLarge(context)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: rs(context, 12)),

              // Route cards list
              if (_routes.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: rs(context, 16)),
                  itemCount: _routes.length,
                  separatorBuilder: (_, __) => SizedBox(height: rs(context, 8)),
                  itemBuilder: (ctx, i) => _buildRouteCard(ctx, _routes[i]),
                ),

              if (_routeError != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      rs(context, 16), 0, rs(context, 16), 0),
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

              SizedBox(height: rs(context, 16)),

              // Start Navigation button
              Padding(
                padding: EdgeInsets.fromLTRB(
                    rs(context, 16), 0, rs(context, 16), rs(context, 30)),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _routes.isEmpty ? null : _startNavigation,
                    icon: const Icon(Icons.navigation_rounded),
                    label: Text(
                      _routes.isEmpty
                          ? 'Loading…'
                          : 'Start  ·  ${_fmtDist(_selectedRoute!.distanceKm)}  ·  ${_fmtDur(_selectedRoute!.durationMinutes)}',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: rs(context, 14)),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(rs(context, 16)),
                      ),
                      textStyle: AppTextStyles.buttonMedium(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, RouteOption route) {
    final isSelected = route.index == _selectedRouteIndex;
    final color = route.color;

    return GestureDetector(
      onTap: () => _selectRoute(route.index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(rs(context, 14)),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.07)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(rs(context, 16)),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          // Colour indicator line
          Container(
            width: 4,
            height: rs(context, 48),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: rs(context, 12)),

          // Route info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(
                    route.label,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  if (route.isFastest) ...[
                    SizedBox(width: rs(context, 6)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: rs(context, 6),
                          vertical: rs(context, 2)),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('FASTEST',
                          style: AppTextStyles.bodySmall(context).copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          )),
                    ),
                  ],
                ]),
                SizedBox(height: rs(context, 2)),
                Text(route.summary,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall(context)
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),

          // Distance + ETA
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmtDur(route.durationMinutes),
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : AppColors.textPrimary,
                ),
              ),
              Text(
                _fmtDist(route.distanceKm),
                style: AppTextStyles.bodySmall(context)
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),

          // Selected check
          SizedBox(width: rs(context, 10)),
          AnimatedOpacity(
            opacity: isSelected ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.check_circle_rounded,
                color: color, size: rs(context, 22)),
          ),
        ]),
      ),
    );
  }

  // ── Navigation Panel (active turn-by-turn) ────────────────────────────────

  Widget _buildNavigationPanel(BuildContext context) {
    final route = _selectedRoute;
    final arrived = _distanceKm < 0.05;

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
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20, offset: const Offset(0, -4),
          )],
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

          if (!arrived && route != null) ...[
            // Next instruction card
            Container(
              padding: EdgeInsets.all(rs(context, 14)),
              decoration: BoxDecoration(
                color: route.color.withOpacity(0.07),
                borderRadius: BorderRadius.circular(rs(context, 16)),
                border: Border.all(color: route.color.withOpacity(0.2)),
              ),
              child: Row(children: [
                Container(
                  padding: EdgeInsets.all(rs(context, 10)),
                  decoration: BoxDecoration(
                    color: route.color,
                    borderRadius: BorderRadius.circular(rs(context, 12)),
                  ),
                  child: Icon(Icons.navigation_rounded,
                      color: Colors.white, size: rs(context, 20)),
                ),
                SizedBox(width: rs(context, 12)),
                Expanded(
                  child: Text(
                    _nextInstruction,
                    style: AppTextStyles.bodyMedium(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ),
            SizedBox(height: rs(context, 12)),

            // Distance & ETA
            Row(children: [
              Expanded(child: _statTile(context,
                icon: Icons.straighten_rounded,
                label: 'Distance',
                value: _fmtDist(_distanceKm),
                color: route.color,
              )),
              SizedBox(width: rs(context, 12)),
              Expanded(child: _statTile(context,
                icon: Icons.timer_rounded,
                label: 'ETA',
                value: _etaMinutes < 1 ? '< 1 min' : _fmtDur(_etaMinutes),
                color: AppColors.secondary,
              )),
            ]),

            SizedBox(height: rs(context, 10)),

            // "Change route" — go back to route selection
            TextButton.icon(
              onPressed: () {
                _locationSub?.cancel();
                setState(() {
                  _navigationStarted = false;
                  _isFollowingUser = false;
                });
                _fitAllRoutes();
              },
              icon: Icon(Icons.alt_route_rounded,
                  size: rs(context, 16), color: AppColors.textSecondary),
              label: Text('Change route',
                  style: AppTextStyles.bodySmall(context)
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ],

          // Arrived
          if (arrived)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(rs(context, 16)),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(rs(context, 16)),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: rs(context, 26)),
                    SizedBox(width: rs(context, 10)),
                    Text("You have arrived!",
                        style: AppTextStyles.bodyLarge(context).copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
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
              style: AppTextStyles.bodyMedium(context)
                  .copyWith(fontWeight: FontWeight.bold, color: color)),
        ]),
      ]),
    );
  }

  // ── Loader ─────────────────────────────────────────────────────────────────

  Widget _buildLoader(BuildContext context) => Center(
    child: Container(
      padding: EdgeInsets.all(rs(context, 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(rs(context, 20)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: rs(context, 14)),
        Text(
          _routeLoading ? 'Finding best routes…' : 'Getting your location…',
          style: AppTextStyles.bodyMedium(context)
              .copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: rs(context, 4)),
        Text(
          _routeLoading
              ? 'Fetching all possible routes'
              : 'Please wait a moment',
          style: AppTextStyles.bodySmall(context)
              .copyWith(color: AppColors.textSecondary),
        ),
      ]),
    ),
  );

  // ── Error widget — 4 distinct states ─────────────────────────────────────
  //
  //  gpsOff        → Open Location Settings  (turn GPS on)
  //  deniedForever → Open App Settings        (then "I enabled it — Try again")
  //  denied        → "Allow location"         (shows OS dialog again, infinite retry)
  //  unknown       → Generic retry

  Widget _buildError(BuildContext context) {
    // Config per state
    final IconData icon;
    final Color iconColor;
    final String title;

    switch (_locState) {
      case _LocationState.gpsOff:
        icon      = Icons.gps_off_rounded;
        iconColor = Colors.orange;
        title     = 'GPS is turned off';
        break;
      case _LocationState.deniedForever:
        icon      = Icons.location_disabled_rounded;
        iconColor = Colors.red;
        title     = 'Location access blocked';
        break;
      case _LocationState.denied:
        icon      = Icons.location_off_rounded;
        iconColor = Colors.red;
        title     = 'Location permission denied';
        break;
      default:
        icon      = Icons.warning_amber_rounded;
        iconColor = Colors.orange;
        title     = 'Something went wrong';
    }

    return Center(
      child: Container(
        margin: EdgeInsets.all(rs(context, 24)),
        padding: EdgeInsets.all(rs(context, 24)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rs(context, 20)),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Icon in a soft circle
          Container(
            padding: EdgeInsets.all(rs(context, 16)),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: rs(context, 36)),
          ),
          SizedBox(height: rs(context, 14)),

          // Title
          Text(
            title,
            style: AppTextStyles.bodyLarge(context)
                .copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: rs(context, 6)),

          // Subtitle / explanation
          Text(
            _locationError ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall(context)
                .copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
          SizedBox(height: rs(context, 22)),

          // ── Buttons per state ─────────────────────────────────────────

          // STATE: GPS off
          if (_locState == _LocationState.gpsOff) ...[
            _errorPrimaryBtn(
              context,
              icon: Icons.settings_rounded,
              label: 'Open Location Settings',
              onTap: () async {
                // Opens device Location Settings (not app settings)
                await Geolocator.openLocationSettings();
              },
            ),
            SizedBox(height: rs(context, 10)),
            _errorOutlineBtn(
              context,
              icon: Icons.refresh_rounded,
              label: 'I turned it on — Try again',
              onTap: _retryInit,
            ),
          ],

          // STATE: Permanently denied → only App Settings can fix
          if (_locState == _LocationState.deniedForever) ...[
            _errorPrimaryBtn(
              context,
              icon: Icons.settings_rounded,
              label: 'Open App Settings',
              onTap: () async {
                // Opens THIS app's permission page in phone Settings
                await Geolocator.openAppSettings();
              },
            ),
            SizedBox(height: rs(context, 10)),
            _errorOutlineBtn(
              context,
              icon: Icons.refresh_rounded,
              label: 'I enabled it — Try again',
              onTap: _retryInit,
            ),
          ],

          // STATE: Denied once — show OS dialog again (infinite retry is fine)
          if (_locState == _LocationState.denied)
            _errorPrimaryBtn(
              context,
              icon: Icons.my_location_rounded,
              label: 'Allow location',
              onTap: _retryInit, // re-runs _initLocation → requestPermission fires
            ),

          // STATE: Unknown error
          if (_locState == _LocationState.unknown)
            _errorPrimaryBtn(
              context,
              icon: Icons.refresh_rounded,
              label: 'Try again',
              onTap: _retryInit,
            ),
        ]),
      ),
    );
  }

  // Helper: resets state and calls _initLocation fresh
  void _retryInit() {
    setState(() {
      _locationError   = null;
      _locationLoading = true;
      _routes          = [];
      _locState        = _LocationState.loading;
    });
    _initLocation();
  }

  Widget _errorPrimaryBtn(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: rs(context, 18)),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: rs(context, 13)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rs(context, 12)),
            ),
            textStyle: AppTextStyles.buttonMedium(context),
          ),
        ),
      );

  Widget _errorOutlineBtn(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) =>
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: rs(context, 18)),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary.withOpacity(0.6)),
            padding: EdgeInsets.symmetric(vertical: rs(context, 13)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rs(context, 12)),
            ),
            textStyle: AppTextStyles.buttonMedium(context),
          ),
        ),
      );

  // ── Re-center FAB ─────────────────────────────────────────────────────────

  Widget _buildRecenterBtn(BuildContext context) => Positioned(
    right: rs(context, 16),
    bottom: rs(context, 220),
    child: GestureDetector(
      onTap: () async {
        if (_currentPosition == null) return;
        setState(() => _isFollowingUser = true);
        await _mapController?.animateCamera(
          _navigationStarted
              ? CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(_currentPosition!.latitude,
                _currentPosition!.longitude),
            zoom: 17, tilt: 50,
            bearing: _currentPosition!.heading,
          ))
              : CameraUpdate.newLatLng(
              LatLng(_currentPosition!.latitude,
                  _currentPosition!.longitude)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(rs(context, 12)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(rs(context, 14)),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12, offset: const Offset(0, 4),
          )],
        ),
        child: Icon(Icons.my_location_rounded,
            color: AppColors.primary, size: rs(context, 24)),
      ),
    ),
  );
}