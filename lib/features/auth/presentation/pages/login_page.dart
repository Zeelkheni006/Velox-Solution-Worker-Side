// // lib/screens/auth/login_screen.dart
//
// import 'package:apilearning/features/dashboard/presentation/pages/dashboard_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// import '../../../../core/constants/app_colors.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _credentialController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   bool _isPasswordVisible = false;
//   bool _isLoading = false;
//   bool _rememberMe = false;
//   bool _isPhoneNumber = false;
//
//   @override
//   void dispose() {
//     _credentialController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   // API Base URL - Replace with your actual URL
//   final String baseUrl = 'http://72.61.245.134:8000';
//
//   // Check if input is a phone number
//   void _checkInputType(String value) {
//     final isPhone = RegExp(r'^[0-9]+$').hasMatch(value.replaceAll(' ', ''));
//     setState(() {
//       _isPhoneNumber = isPhone;
//     });
//   }
//
//   // Get formatted credential for API
//   String _getFormattedCredential() {
//     String credential = _credentialController.text.trim();
//
//     // If it's a phone number, ensure it has +91 prefix
//     if (_isPhoneNumber) {
//       credential = credential.replaceAll(' ', '');
//       if (!credential.startsWith('+91')) {
//         credential = '+91$credential';
//       }
//     }
//
//     return credential;
//   }
//
//   Future<void> _loginWithPassword() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/v1/worker/auth/login/through/password'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'credential': _getFormattedCredential(),
//           'password': _passwordController.text,
//         }),
//       );
//
//       final data = jsonDecode(response.body);
//
//       if (response.statusCode == 200 && data['success'] == true) {
//         Navigator.of(context).push(
//           MaterialPageRoute(builder: (context) => const DashboardPage()),
//         );
//       } else {
//         final message = data['message'] ?? 'Login failed';
//         _showSnackBar(message, AppColors.error);
//       }
//     } catch (e) {
//       _showSnackBar('Connection error. Please try again.', AppColors.error);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _loginWithOTP() async {
//     if (_credentialController.text.isEmpty) {
//       _showSnackBar('Please enter email or phone number', AppColors.warning);
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/v1/worker/auth/login/through/otp'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'credential': _getFormattedCredential(),
//         }),
//       );
//
//       final data = jsonDecode(response.body);
//
//       if (response.statusCode == 200) {
//         _showSnackBar('OTP sent successfully!', AppColors.success);
//         // Navigate to OTP verification screen
//         // Navigator.pushNamed(context, '/otp-verify', arguments: _getFormattedCredential());
//       } else {
//         final message = data['message'] ?? 'Failed to send OTP';
//         _showSnackBar(message, AppColors.error);
//       }
//     } catch (e) {
//       _showSnackBar('Connection error. Please try again.', AppColors.error);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _showForgotPasswordDialog() {
//     final emailController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: AppColors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'Forgot Password',
//           style: TextStyle(
//             color: AppColors.primary,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Enter your email address to receive a password reset link.',
//               style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: emailController,
//               keyboardType: TextInputType.emailAddress,
//               decoration: InputDecoration(
//                 labelText: 'Email Address',
//                 labelStyle: const TextStyle(color: AppColors.textSecondary),
//                 prefixIcon: const Icon(Icons.email_outlined, color: AppColors.secondary),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: AppColors.border),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: AppColors.secondary, width: 2),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (emailController.text.isEmpty) {
//                 _showSnackBar('Please enter email address', AppColors.warning);
//                 return;
//               }
//
//               Navigator.pop(context);
//               await _sendPasswordResetRequest(emailController.text);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.secondary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('Send Reset Link', style: TextStyle(color: AppColors.white)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _sendPasswordResetRequest(String email) async {
//     setState(() => _isLoading = true);
//
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/v1/worker/auth/forgot-password/initiate'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email}),
//       );
//
//       final data = jsonDecode(response.body);
//
//       if (response.statusCode == 200) {
//         _showSnackBar('Password reset link sent to your email!', AppColors.success);
//       } else {
//         final message = data['message'] ?? 'Failed to send reset link';
//         _showSnackBar(message, AppColors.error);
//       }
//     } catch (e) {
//       _showSnackBar('Connection error. Please try again.', AppColors.error);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _showSnackBar(String message, Color backgroundColor) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: backgroundColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Logo or Brand Section
//                   Container(
//                     height: 100,
//                     width: 100,
//                     decoration: BoxDecoration(
//                       color: AppColors.primary,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Icon(
//                       Icons.business_center,
//                       size: 50,
//                       color: AppColors.secondary,
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//
//                   // Title
//                   const Text(
//                     'Welcome Back',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: AppColors.primary,
//                       fontSize: 28,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Sign in to continue',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: AppColors.textSecondary,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//
//                   // Email/Phone Input with +91 prefix
//                   TextFormField(
//                     controller: _credentialController,
//                     keyboardType: TextInputType.emailAddress,
//                     onChanged: _checkInputType,
//                     inputFormatters: [
//                       if (_isPhoneNumber)
//                         FilteringTextInputFormatter.digitsOnly,
//                       if (_isPhoneNumber)
//                         LengthLimitingTextInputFormatter(10),
//                     ],
//                     decoration: InputDecoration(
//                       labelText: 'Email or Phone Number',
//                       labelStyle: const TextStyle(color: AppColors.textSecondary),
//                       prefixIcon: const Icon(Icons.person_outline, color: AppColors.secondary),
//                       prefixText: _isPhoneNumber ? '+91 ' : null,
//                       prefixStyle: const TextStyle(
//                         color: AppColors.primary,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                       filled: true,
//                       fillColor: AppColors.surface,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: AppColors.border),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: AppColors.border),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: AppColors.secondary, width: 2),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your email or phone number';
//                       }
//                       if (_isPhoneNumber && value.length != 10) {
//                         return 'Phone number must be 10 digits';
//                       }
//                       if (!_isPhoneNumber && !value.contains('@')) {
//                         return 'Please enter a valid email';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//
//                   // Password Input
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: !_isPasswordVisible,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       labelStyle: const TextStyle(color: AppColors.textSecondary),
//                       prefixIcon: const Icon(Icons.lock_outline, color: AppColors.secondary),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                           color: AppColors.grey,
//                         ),
//                         onPressed: () {
//                           setState(() => _isPasswordVisible = !_isPasswordVisible);
//                         },
//                       ),
//                       filled: true,
//                       fillColor: AppColors.surface,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: AppColors.border),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: AppColors.border),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: const BorderSide(color: AppColors.secondary, width: 2),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your password';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//
//                   // Remember Me & Forgot Password
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           SizedBox(
//                             height: 24,
//                             width: 24,
//                             child: Checkbox(
//                               value: _rememberMe,
//                               onChanged: (value) {
//                                 setState(() => _rememberMe = value ?? false);
//                               },
//                               activeColor: AppColors.secondary,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           const Text(
//                             'Remember me',
//                             style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
//                           ),
//                         ],
//                       ),
//                       TextButton(
//                         onPressed: _showForgotPasswordDialog,
//                         child: const Text(
//                           'Forgot Password?',
//                           style: TextStyle(
//                             color: AppColors.secondary,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Login Button
//                   SizedBox(
//                     height: 56,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _loginWithPassword,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.secondary,
//                         disabledBackgroundColor: AppColors.greyLight,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 2,
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                         height: 24,
//                         width: 24,
//                         child: CircularProgressIndicator(
//                           color: AppColors.white,
//                           strokeWidth: 2,
//                         ),
//                       )
//                           : const Text(
//                         'Login',
//                         style: TextStyle(
//                           color: AppColors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//
//                   // OR Divider
//                   const Row(
//                     children: [
//                       Expanded(child: Divider(color: AppColors.border, thickness: 1)),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Text(
//                           'OR',
//                           style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
//                         ),
//                       ),
//                       Expanded(child: Divider(color: AppColors.border, thickness: 1)),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//
//                   // Login with OTP Button
//                   SizedBox(
//                     height: 56,
//                     child: OutlinedButton.icon(
//                       onPressed: _isLoading ? null : _loginWithOTP,
//                       icon: const Icon(Icons.message, color: AppColors.primary, size: 20),
//                       label: const Text(
//                         'Login with OTP',
//                         style: TextStyle(
//                           color: AppColors.primary,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: AppColors.primary, width: 2),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }