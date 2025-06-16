import 'package:flutter/material.dart';
import 'package:moelung_new/config/app_routes.dart';
import 'package:moelung_new/models/user_model.dart'; // Import UserModel
import 'package:moelung_new/utils/app_colors.dart'; // Import AppColors
import 'package:moelung_new/widgets/common/page_header.dart'; // Import PageHeader

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'test@example.com'); // Pre-fill with dummy email
  final TextEditingController _passwordController = TextEditingController(text: 'password123'); // Pre-fill with dummy password

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // For demonstration, create a dummy user
    final user = UserModel(
      id: 'user123',
      name: 'Test User',
      email: _emailController.text,
    );

    // Navigate to home and pass the user model
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.home,
      arguments: user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Use themed background color
      body: SingleChildScrollView( // Allow scrolling for smaller screens
        child: Column(
          children: [
            const PageHeader(title: 'Login'), // Add PageHeader
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/logo.png', // Use the app logo
                    height: 120,
                  ),
                  const SizedBox(height: 32.0),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email, color: AppColors.dark), // Themed icon
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: AppColors.accent.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock, color: AppColors.dark), // Themed icon
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: AppColors.accent.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity, // Make button full width
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // Themed button color
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.register);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.dark, // Themed text color
                    ),
                    child: const Text('Don\'t have an account? Register here.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
