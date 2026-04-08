// // lib/features/profile/presentation/pages/availability_settings_page.dart
//
// import 'package:flutter/material.dart';
// import '../../../../core/constants/app_colors.dart';
//
// class AvailabilitySettingsPage extends StatefulWidget {
//   const AvailabilitySettingsPage({super.key});
//
//   @override
//   State<AvailabilitySettingsPage> createState() => _AvailabilitySettingsPageState();
// }
//
// class _AvailabilitySettingsPageState extends State<AvailabilitySettingsPage> {
//   final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
//
//   // Simulated availability map: Day -> [Start Time, End Time]
//   Map<String, List<String>?> _availability = {
//     'Monday': ['09:00', '18:00'],
//     'Tuesday': ['09:00', '18:00'],
//     'Wednesday': ['09:00', '18:00'],
//     'Thursday': ['09:00', '18:00'],
//     'Friday': ['09:00', '18:00'],
//     'Saturday': null, // Unavailable
//     'Sunday': null, // Unavailable
//   };
//
//   Future<void> _selectTime(BuildContext context, String day, bool isStart) async {
//     final initialTime = TimeOfDay.now();
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: initialTime,
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData(
//             colorScheme: ColorScheme.light(
//               primary: AppColors.secondary,
//               onPrimary: AppColors.white,
//               surface: AppColors.white,
//               onSurface: AppColors.textPrimary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       // Format time to 'HH:mm' for backend consistency
//       final formattedTime = picked.hour.toString().padLeft(2, '0') + ':' + picked.minute.toString().padLeft(2, '0');
//
//       setState(() {
//         if (_availability[day] == null) {
//           // If day was previously off, set default opposite time
//           _availability[day] = isStart ? [formattedTime, '18:00'] : ['09:00', formattedTime];
//         } else {
//           // Update specific slot
//           isStart ? _availability[day]![0] = formattedTime : _availability[day]![1] = formattedTime;
//         }
//       });
//     }
//   }
//
//   void _toggleDayAvailability(String day, bool isAvailable) {
//     setState(() {
//       if (isAvailable) {
//         // Set to default working hours if toggled on
//         _availability[day] = ['09:00', '18:00'];
//       } else {
//         _availability[day] = null; // Mark as unavailable
//       }
//     });
//   }
//
//   void _saveAvailability() {
//     // TODO: Implement API call to save _availability map to the backend
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Availability Updated Successfully!')),
//     );
//     Navigator.of(context).pop();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Availability Settings'),
//         elevation: 1,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           Text(
//             'Define your daily working hours. Only available during these slots.',
//             style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
//           ),
//           const Divider(height: 30),
//           ..._days.map((day) {
//             final available = _availability[day] != null;
//             final startTime = available ? _availability[day]![0] : '-';
//             final endTime = available ? _availability[day]![1] : '-';
//
//             return Card(
//               margin: const EdgeInsets.only(bottom: 10),
//               color: available ? AppColors.surface : AppColors.greyLight.withOpacity(0.5),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     // Day and Toggle
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           day,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: available ? AppColors.textPrimary : AppColors.textDisabled,
//                           ),
//                         ),
//                         Switch(
//                           value: available,
//                           onChanged: (val) => _toggleDayAvailability(day, val),
//                           activeColor: AppColors.success,
//                           inactiveThumbColor: AppColors.grey,
//                         ),
//                       ],
//                     ),
//
//                     if (available)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: Row(
//                           children: [
//                             // Start Time Button
//                             Expanded(
//                               child: _buildTimeButton(context, 'Start Time', startTime, () => _selectTime(context, day, true)),
//                             ),
//                             const SizedBox(width: 10),
//                             // End Time Button
//                             Expanded(
//                               child: _buildTimeButton(context, 'End Time', endTime, () => _selectTime(context, day, false)),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ElevatedButton(
//           onPressed: _saveAvailability,
//           child: const Text('SAVE AVAILABILITY'),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTimeButton(BuildContext context, String label, String time, VoidCallback onTap) {
//     return OutlinedButton(
//       onPressed: onTap,
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppColors.primary,
//         side: const BorderSide(color: AppColors.border),
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//       child: Column(
//         children: [
//           Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
//           const SizedBox(height: 4),
//           Text(
//             time,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//               color: AppColors.primary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }