import 'package:flutter/material.dart';
import 'package:moelung_new/config/app_routes.dart';
import 'package:moelung_new/models/user_model.dart'; // Import UserModel
import 'package:moelung_new/utils/app_colors.dart'; // Import AppColors
import 'package:moelung_new/widgets/common/page_header.dart'; // Import PageHeader
import 'package:moelung_new/models/enums/user_role.dart'; // Import UserRole enum

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'penyetoer.budi@example.com');
  final TextEditingController _passwordController = TextEditingController(text: 'rahasia123');
  bool _obscureText = true;
  UserRole _selectedRole = UserRole.penyetoer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    // For demonstration, create a dummy user with ID matching dummy data
    final String userId = _selectedRole == UserRole.penyetoer
        ? 'penyetoer_id_default'
        : 'kolektoer_id_default';

    final user = UserModel(
      id: userId,
      name: _selectedRole == UserRole.penyetoer ? 'Budi Santoso' : 'Siti Rahayu',
      email: _emailController.text,
      role: _selectedRole,
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
            const PageHeader(title: 'Masuk', showBackButton: false), // Translated
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
                      labelText: 'Email', // Kept as 'Email'
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
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi', // Translated
                      prefixIcon: const Icon(Icons.lock, color: AppColors.dark), // Themed icon
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.dark,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
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
                  const SizedBox(height: 16.0), // Add spacing before role selection
                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Masuk sebagai', // Translated
                      prefixIcon: const Icon(Icons.person, color: AppColors.dark),
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
                    items: UserRole.values.map((UserRole role) {
                      return DropdownMenuItem<UserRole>(
                        value: role,
                        child: Text(role.label),
                      );
                    }).toList(),
                    onChanged: (UserRole? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedRole = newValue;
                        });
                      }
                    },
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
                        'Masuk', // Translated
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
                    child: const Text('Belum punya akun? Daftar di sini.'), // Translated
                  ),
                  const SizedBox(height: 8.0), // Add some spacing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Pass a dummy user for TOS/Privacy Policy screens as they require a user model
                          Navigator.of(context).pushNamed(
                            AppRoutes.termsOfService,
                            arguments: UserModel(id: 'guest', name: 'Guest', email: 'guest@example.com', role: UserRole.penyetoer),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                        ),
                        child: const Text('Ketentuan Layanan'),
                      ),
                      const Text(' | ', style: TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () {
                          // Pass a dummy user for TOS/Privacy Policy screens as they require a user model
                          Navigator.of(context).pushNamed(
                            AppRoutes.privacyPolicy,
                            arguments: UserModel(id: 'guest', name: 'Guest', email: 'guest@example.com', role: UserRole.penyetoer),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.secondary,
                        ),
                        child: const Text('Kebijakan Privasi'),
                      ),
                    ],
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
