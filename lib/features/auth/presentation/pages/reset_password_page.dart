// // lib/features/auth/presentation/pages/reset_password_page.dart
//
// import 'package:flutter/material.dart';
//
// import '../../../../core/constants/app_colors.dart';
// import 'login_page.dart';
//
// class ResetPasswordPage extends StatelessWidget {
//   const ResetPasswordPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Set New Password'),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             Icon(
//               Icons.vpn_key,
//               color: AppColors.primary,
//               size: 70,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Create a Strong Password',
//               style: Theme.of(context).textTheme.headlineLarge,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 40),
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
//             // Final Reset Button
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Implement final API call to reset password.
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Password reset successfully! Please login.')),
//                 );
//                 // Redirect to the Login Page
//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(builder: (context) => const LoginPage()),
//                       (Route<dynamic> route) => false,
//                 );
//               },
//               child: const Text('RESET PASSWORD'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }