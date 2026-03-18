// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../../app/modules/login/views/login_view.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/providers/worker_status_provider.dart';
// import '../../../../core/providers/order_provider.dart';
// import '../../../../data/models/worker_model.dart';
// import '../../../auth/presentation/pages/login_page.dart';
// import 'availability_settings_page.dart';
//
// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});
//
//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }
//
// class _ProfilePageState extends State<ProfilePage> {
//   // Worker data (in production, fetch from API/Provider)
//   final WorkerModel _worker = WorkerModel(
//     id: 'W001',
//     fullName: 'Ravi Sharma',
//     email: 'ravi.sharma@velox.com',
//     phoneNumber: '+91 98765 43210',
//     serviceSpecialty: 'AC Repair & Service',
//     rating: 4.7,
//     completedJobs: 0, // Will be updated from OrderProvider
//     isOnline: true,
//     profilePhotoUrl: null,
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer2<WorkerStatusProvider, OrderProvider>(
//       builder: (context, statusProvider, orderProvider, child) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('My Profile'),
//             elevation: 0,
//             backgroundColor: AppColors.appbar,
//           ),
//           body: SingleChildScrollView(
//             child: Column(
//               children: [
//                 _buildProfileHeader(context, statusProvider),
//                 const SizedBox(height: 20),
//                 _buildPerformanceMetrics(context, orderProvider),
//                 const SizedBox(height: 20),
//                 _buildSettingsList(context),
//                 const SizedBox(height: 40),
//
//                 // Logout Button
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       _showLogoutDialog(context);
//                     },
//                     icon: const Icon(Icons.logout, color: AppColors.error),
//                     label: const Text('Logout'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: AppColors.error,
//                       side: const BorderSide(color: AppColors.error),
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       minimumSize: const Size(double.infinity, 0),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildProfileHeader(
//       BuildContext context, WorkerStatusProvider statusProvider) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.appbar,
//             AppColors.primary.withOpacity(0.1),
//           ],
//         ),
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 50,
//             backgroundColor: AppColors.secondary.withOpacity(0.2),
//             child: const Icon(
//               Icons.person,
//               size: 50,
//               color: AppColors.secondary,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             _worker.fullName,
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             _worker.serviceSpecialty,
//             style: const TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: 16,
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           // Online Status Switch
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             decoration: BoxDecoration(
//               color: statusProvider.isOnline
//                   ? AppColors.success.withOpacity(0.15)
//                   : AppColors.error.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(30),
//               border: Border.all(
//                 color: statusProvider.isOnline
//                     ? AppColors.success
//                     : AppColors.error,
//                 width: 2,
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 12,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: statusProvider.isOnline
//                         ? AppColors.success
//                         : AppColors.error,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   statusProvider.isOnline ? 'ONLINE' : 'OFFLINE',
//                   style: TextStyle(
//                     color: statusProvider.isOnline
//                         ? AppColors.success
//                         : AppColors.error,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Switch(
//                   value: statusProvider.isOnline,
//                   onChanged: (newValue) {
//                     statusProvider.setStatus(newValue);
//
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(
//                           newValue
//                               ? 'You are now Online! Ready to accept orders.'
//                               : 'You are now Offline. You won\'t receive new orders.',
//                         ),
//                         backgroundColor:
//                         newValue ? AppColors.success : AppColors.error,
//                         behavior: SnackBarBehavior.floating,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         duration: const Duration(seconds: 2),
//                       ),
//                     );
//                   },
//                   activeColor: AppColors.success,
//                   inactiveThumbColor: AppColors.error,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPerformanceMetrics(
//       BuildContext context, OrderProvider orderProvider) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildMetric(
//             'Rating',
//             '${_worker.rating.toStringAsFixed(1)} ★',
//             AppColors.secondary,
//             Icons.star,
//           ),
//           Container(width: 1, height: 50, color: AppColors.greyLight),
//           _buildMetric(
//             'Jobs Done',
//             orderProvider.completedJobsCount.toString(),
//             AppColors.primary,
//             Icons.check_circle,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMetric(String title, String value, Color color, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 30),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           title,
//           style: const TextStyle(
//             color: AppColors.textSecondary,
//             fontSize: 14,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSettingsList(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 2,
//       child: Column(
//         children: [
//           _buildProfileTile(
//             context,
//             Icons.access_time,
//             'Manage Availability',
//                 () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => const AvailabilitySettingsPage(),
//                 ),
//               );
//             },
//           ),
//           const Divider(height: 1),
//           _buildProfileTile(
//             context,
//             Icons.lock_outline,
//             'Change Password',
//                 () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Change Password - Coming Soon'),
//                 ),
//               );
//             },
//           ),
//           const Divider(height: 1),
//           _buildProfileTile(
//             context,
//             Icons.edit,
//             'Edit Profile Details',
//                 () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Edit Profile - Coming Soon'),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   ListTile _buildProfileTile(
//       BuildContext context, IconData icon, String title, VoidCallback onTap) {
//     return ListTile(
//       leading: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: AppColors.primary.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, color: AppColors.primary),
//       ),
//       title: Text(title),
//       trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
//       onTap: onTap,
//     );
//   }
//
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (context) => const LoginScreen()),
//                     (route) => false,
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.error,
//             ),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }
// }