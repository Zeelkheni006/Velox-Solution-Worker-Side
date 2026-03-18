// // lib/features/auth/presentation/pages/forgot_password_page.dart
//
// import 'package:flutter/material.dart';
//
// import '../../../../core/constants/app_colors.dart';
// import 'otp_verification_page.dart';
// // NOTE: We will create OtpVerificationPage next
//
// class ForgotPasswordPage extends StatelessWidget {
//   const ForgotPasswordPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Forgot Password'),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             Icon(
//               Icons.lock_reset,
//               color: AppColors.secondary,
//               size: 70,
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Reset Your Password',
//               style: Theme.of(context).textTheme.headlineLarge,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Enter your registered email or phone number to receive a verification code.',
//               style: TextStyle(color: AppColors.textSecondary),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 40),
//
//             // Email/Phone Input Field
//             TextFormField(
//               keyboardType: TextInputType.emailAddress,
//               decoration: const InputDecoration(
//                 labelText: 'Email or Phone Number',
//                 prefixIcon: Icon(Icons.person_outline),
//               ),
//             ),
//             const SizedBox(height: 40),
//
//             // Send OTP Button
//             ElevatedButton(
//               onPressed: () {
//                 // TODO: Implement API call to request OTP.
//                 // Assuming success, navigate to OTP Verification Page.
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => const OtpVerificationPage(
//                       contactDetail: 'ravi.sharma@velox.com', // Pass the user's input here
//                     ),
//                   ),
//                 );
//               },
//               child: const Text('SEND VERIFICATION CODE'),
//             ),
//             const SizedBox(height: 20),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Back to Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }