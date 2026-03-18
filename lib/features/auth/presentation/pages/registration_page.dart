// lib/features/auth/presentation/pages/registration_page.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Registration'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 16),
              Text(
                'Join the Velox Network',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Full Name Input
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
              ),
              const SizedBox(height: 20),

              // Email Input
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 20),

              // Phone Number Input
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) => value == null || value.length < 10 ? 'Enter a valid phone number' : null,
              ),
              const SizedBox(height: 20),

              // Service Specialty Dropdown/Input (Simplified)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Service Specialty (e.g., AC Repair)',
                  prefixIcon: Icon(Icons.handyman_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // Password Input
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 40),

              // Register Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Implement registration API call
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration successful! Redirecting to login...')),
                    );
                    Navigator.of(context).pop(); // Go back to LoginPage
                  }
                },
                child: const Text('REGISTER ACCOUNT'),
              ),
              const SizedBox(height: 20),

              // Back to Login Link
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Already have an account? Log In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}