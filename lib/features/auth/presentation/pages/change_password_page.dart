// // lib/features/auth/presentation/pages/change_password_page.dart
//
// import 'package:flutter/material.dart';
// import '../../../../core/constants/app_colors.dart';
//
// class ChangePasswordPage extends StatelessWidget {
//   const ChangePasswordPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Change Password'),
//         elevation: 1,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             Text(
//               'Update your security credentials.',
//               style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
//             ),
//             const SizedBox(height: 30),
//
//             // Current Password Input
//             TextFormField(
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'Current Password',
//                 prefixIcon: Icon(Icons.lock_outline),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // New Password Input
//             TextFormField(
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'New Password',
//                 prefixIcon: Icon(Icons.lock_open),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // Confirm New Password Input
//             TextFormField(
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'Confirm New Password',
//                 prefixIcon: Icon(Icons.check),
//               ),
//             ),
//             const SizedBox(height: 40),
//
//             // Save Button
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Implement API call to change password
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Password changed successfully!')),
//                 );
//                 Navigator.of(context).pop();
//               },
//               child: const Text('UPDATE PASSWORD'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }