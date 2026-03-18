// // lib/features/dashboard/presentation/pages/dashboard_page.dart
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/providers/worker_status_provider.dart';
// import '../../../orders/presentation/pages/current_orders_list.dart';
// import '../../../orders/presentation/pages/old_orders_list.dart';
// import '../../../orders/presentation/pages/upcoming_orders_list.dart';
// import '../../../profile/presentation/pages/profile_page.dart';
//
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   int _selectedIndex = 0;
//
//   // Tabs for the order management system
//   final List<Tab> _tabs = const [
//     Tab(text: 'Current', icon: Icon(Icons.access_time_filled)),
//     Tab(text: 'Upcoming', icon: Icon(Icons.schedule)),
//     Tab(text: 'Old', icon: Icon(Icons.history)),
//   ];
//
//   // The content corresponding to each tab
//   final List<Widget> _tabViews = [
//     CurrentOrdersList(),
//     UpcomingOrdersList(),
//     OldOrdersList(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabs.length, vsync: this);
//     _tabController.addListener(() {
//       setState(() {
//         _selectedIndex = _tabController.index;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<WorkerStatusProvider>(
//       builder: (context, statusProvider, child) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Velox Partner Dashboard'),
//             actions: [
//               // Status Indicator Badge
//               Padding(
//                 padding: const EdgeInsets.only(right: 8.0),
//                 child: Center(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: statusProvider.isOnline
//                           ? AppColors.success.withOpacity(0.2)
//                           : AppColors.error.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: statusProvider.isOnline ? AppColors.success : AppColors.error,
//                         width: 1.5,
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           width: 8,
//                           height: 8,
//                           decoration: BoxDecoration(
//                             color: statusProvider.isOnline ? AppColors.success : AppColors.error,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           statusProvider.isOnline ? 'ONLINE' : 'OFFLINE',
//                           style: TextStyle(
//                             color: statusProvider.isOnline ? AppColors.success : AppColors.error,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               // Profile Button
//               IconButton(
//                 icon: const Icon(Icons.account_circle, size: 28),
//                 color: AppColors.primary,
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(builder: (context) => const ProfilePage()),
//                   );
//                 },
//               ),
//             ],
//             bottom: TabBar(
//               controller: _tabController,
//               tabs: _tabs,
//               labelColor: AppColors.secondary,
//               unselectedLabelColor: AppColors.textSecondary,
//               indicatorColor: AppColors.secondary,
//               indicatorWeight: 4,
//               indicatorSize: TabBarIndicatorSize.tab,
//             ),
//           ),
//           body: TabBarView(
//             controller: _tabController,
//             children: _tabViews,
//           ),
//           // Show FAB only when worker is OFFLINE
//           floatingActionButton: !statusProvider.isOnline
//               ? FloatingActionButton.extended(
//             onPressed: () {
//               statusProvider.setStatus(true);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: const Text('You are now Online!'),
//                   backgroundColor: AppColors.success,
//                   behavior: SnackBarBehavior.floating,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               );
//             },
//             label: const Text('Go Online'),
//             icon: const Icon(Icons.electric_bolt),
//             backgroundColor: AppColors.success,
//           )
//               : null,
//         );
//       },
//     );
//   }
// }