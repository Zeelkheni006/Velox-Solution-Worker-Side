// // lib/features/auth/presentation/pages/otp_verification_page.dart
//
// import 'package:apilearning/features/auth/presentation/pages/reset_password_page.dart';
// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
//
// import '../../../../core/constants/app_colors.dart'; // Recommended for OTP fields (add to pubspec.yaml)
//
// class OtpVerificationPage extends StatelessWidget {
//   final String contactDetail;
//   const OtpVerificationPage({super.key, required this.contactDetail});
//
//   @override
//   Widget build(BuildContext context) {
//     // Pinput default theme setup (using your colors)
//     final defaultPinTheme = PinTheme(
//       width: 56,
//       height: 56,
//       textStyle: TextStyle(
//         fontSize: 20,
//         color: AppColors.textPrimary,
//         fontWeight: FontWeight.w600,
//       ),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.border),
//         borderRadius: BorderRadius.circular(10),
//       ),
//     );
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Verify Code'),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             Text(
//               'Enter the 6-digit code sent to:',
//               style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 5),
//             Text(
//               contactDetail,
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 40),
//
//             // OTP Input Field (using Pinput package)
//             Center(
//               child: Pinput(
//                 length: 6,
//                 defaultPinTheme: defaultPinTheme,
//                 focusedPinTheme: defaultPinTheme.copyDecorationWith(
//                   border: Border.all(color: AppColors.secondary, width: 2),
//                 ),
//                 onCompleted: (pin) {
//                   // Auto-submit when 6 digits are entered
//                   _verifyAndResetPassword(context, pin);
//                 },
//               ),
//             ),
//             const SizedBox(height: 40),
//
//             // Resend Code Button
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text('Didn\'t receive the code?'),
//                 TextButton(
//                   onPressed: () {
//                     // TODO: Implement Resend OTP API call
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Verification code resent!')),
//                     );
//                   },
//                   child: const Text('Resend Code'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             // Manual Verification Button (for users not using auto-submit)
//             ElevatedButton(
//               onPressed: () {
//                 // Manually trigger verification (assuming you grab the Pinput value here)
//                 _verifyAndResetPassword(context, '123456');
//               },
//               child: const Text('VERIFY CODE'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _verifyAndResetPassword(BuildContext context, String otp) {
//     // TODO: Implement API call to verify OTP.
//
//     // Assuming successful verification:
//     // Navigate to the final password setting screen.
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
//     );
//   }
// }