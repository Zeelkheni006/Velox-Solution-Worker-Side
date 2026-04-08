// // lib/features/orders/presentation/pages/order_map_view.dart
//
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:async';
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../../data/models/order_model.dart';
//
// class OrderMapView extends StatefulWidget {
//   final OrderModel order;
//   const OrderMapView({super.key, required this.order});
//
//   @override
//   State<OrderMapView> createState() => _OrderMapViewState();
// }
//
// class _OrderMapViewState extends State<OrderMapView> {
//   GoogleMapController? _mapController;
//   Position? _currentPosition;
//   Timer? _locationTimer;
//   double _distanceToCustomer = 0.0;
//   bool _hasArrived = false;
//
//   late CameraPosition _initialCameraPosition;
//   final Set<Marker> _markers = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _initialCameraPosition = CameraPosition(
//       target: LatLng(widget.order.customerLat, widget.order.customerLon),
//       zoom: 13,
//     );
//     _checkAndStartLocationTracking();
//   }
//
//   @override
//   void dispose() {
//     _locationTimer?.cancel();
//     _mapController?.dispose();
//     super.dispose();
//   }
//
//   Future<void> _checkAndStartLocationTracking() async {
//     // Check permissions
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Location permission is required for navigation'),
//               backgroundColor: AppColors.error,
//             ),
//           );
//         }
//         return;
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please enable location from settings'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//       }
//       return;
//     }
//
//     // Get initial location
//     try {
//       _currentPosition = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       _updateMapAndMarkers(_currentPosition!);
//
//       // Start periodic tracking
//       _locationTimer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
//         _fetchWorkerLocation();
//       });
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error getting location: $e'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//       }
//     }
//   }
//
//   Future<void> _fetchWorkerLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       if (mounted) {
//         setState(() {
//           _currentPosition = position;
//         });
//         _updateMapAndMarkers(position);
//       }
//     } catch (e) {
//       print("Error fetching location: $e");
//     }
//   }
//
//   void _updateMapAndMarkers(Position position) {
//     final workerLatLng = LatLng(position.latitude, position.longitude);
//     final customerLatLng = LatLng(widget.order.customerLat, widget.order.customerLon);
//
//     // Calculate distance
//     _distanceToCustomer = Geolocator.distanceBetween(
//       position.latitude,
//       position.longitude,
//       widget.order.customerLat,
//       widget.order.customerLon,
//     ) / 1000; // Convert to km
//
//     // Check if arrived (within 100 meters)
//     if (_distanceToCustomer <= 0.1 && !_hasArrived) {
//       setState(() {
//         _hasArrived = true;
//       });
//       _showArrivedDialog();
//     }
//
//     // Update markers
//     setState(() {
//       _markers.clear();
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('workerLocation'),
//           position: workerLatLng,
//           infoWindow: const InfoWindow(title: 'Your Location'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         ),
//       );
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('customerLocation'),
//           position: customerLatLng,
//           infoWindow: InfoWindow(
//             title: widget.order.customerName,
//             snippet: widget.order.customerAddress,
//           ),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ),
//       );
//     });
//
//     // Animate camera
//     _mapController?.animateCamera(CameraUpdate.newLatLng(workerLatLng));
//   }
//
//   void _showArrivedDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: const [
//             Icon(Icons.check_circle, color: AppColors.success, size: 30),
//             SizedBox(width: 10),
//             Text('You Have Arrived!'),
//           ],
//         ),
//         content: const Text(
//           'You are now at the customer location. Please proceed to verify the OTP with the customer.',
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context); // Go back to order details
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.success,
//             ),
//             child: const Text('Proceed to Verify OTP'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Navigate to Customer'),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.white,
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             mapType: MapType.normal,
//             initialCameraPosition: _initialCameraPosition,
//             markers: _markers,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             zoomControlsEnabled: false,
//             onMapCreated: (GoogleMapController controller) {
//               _mapController = controller;
//               if (_currentPosition != null) {
//                 _updateMapAndMarkers(_currentPosition!);
//               }
//             },
//           ),
//
//           // Top Info Card
//           Positioned(
//             top: 16,
//             left: 16,
//             right: 16,
//             child: Card(
//               elevation: 8,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         CircleAvatar(
//                           backgroundColor: AppColors.secondary.withOpacity(0.1),
//                           child: const Icon(
//                             Icons.person,
//                             color: AppColors.secondary,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 widget.order.customerName,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               Text(
//                                 widget.order.serviceName,
//                                 style: const TextStyle(
//                                   color: AppColors.textSecondary,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Divider(height: 24),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         _buildInfoChip(
//                           Icons.navigation,
//                           _currentPosition == null
//                               ? 'Loading...'
//                               : '${_distanceToCustomer.toStringAsFixed(2)} km',
//                           AppColors.secondary,
//                         ),
//                         _buildInfoChip(
//                           Icons.access_time,
//                           '~${(_distanceToCustomer * 3).toStringAsFixed(0)} min',
//                           AppColors.primary,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Bottom Action Button
//           Positioned(
//             bottom: 24,
//             left: 24,
//             right: 24,
//             child: Column(
//               children: [
//                 if (!_hasArrived)
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: AppColors.warning.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const [
//                         Icon(Icons.drive_eta, color: AppColors.white),
//                         SizedBox(width: 8),
//                         Text(
//                           'Traveling to Customer...',
//                           style: TextStyle(
//                             color: AppColors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton.icon(
//                     onPressed: _hasArrived
//                         ? () {
//                       Navigator.pop(context);
//                     }
//                         : null,
//                     icon: const Icon(Icons.check_circle_outline),
//                     label: Text(
//                       _hasArrived ? 'ARRIVED - VERIFY OTP' : 'ARRIVING SOON',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor:
//                       _hasArrived ? AppColors.success : AppColors.grey,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 TextButton.icon(
//                   onPressed: () => _handleLocationIssue(context),
//                   icon: const Icon(Icons.warning_amber, color: AppColors.error),
//                   label: const Text(
//                     'Report Location Issue',
//                     style: TextStyle(color: AppColors.error),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoChip(IconData icon, String text, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: color, width: 1),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 18, color: color),
//           const SizedBox(width: 6),
//           Text(
//             text,
//             style: TextStyle(
//               color: color,
//               fontWeight: FontWeight.w600,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _handleLocationIssue(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: const [
//             Icon(Icons.warning_amber, color: AppColors.error),
//             SizedBox(width: 8),
//             Text('Location Issue'),
//           ],
//         ),
//         content: const Text(
//           'The customer location appears incorrect or you cannot find the address. What would you like to do?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               // TODO: Implement call functionality
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Calling customer...'),
//                   backgroundColor: AppColors.secondary,
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.secondary,
//             ),
//             child: const Text('Call Customer'),
//           ),
//         ],
//       ),
//     );
//   }
// }