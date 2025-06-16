import 'package:flutter/material.dart';
import 'package:moelung_new/config/app_routes.dart';
import 'package:moelung_new/models/user_model.dart'; // Import UserModel
import 'package:moelung_new/utils/app_colors.dart'; // Import AppColors
import 'package:moelung_new/widgets/common/page_header.dart'; // Import PageHeader
import 'package:moelung_new/models/enums/user_role.dart'; // Import UserRole enum
import 'package:flutter/gestures.dart'; // Import for TapGestureRecognizer

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Siti Rahayu'); // Pre-fill with Indonesian dummy name
  final TextEditingController _emailController = TextEditingController(text: 'siti.rahayu@example.com'); // Pre-fill with Indonesian dummy email
  final TextEditingController _passwordController = TextEditingController(text: 'sangataman'); // Pre-fill with Indonesian dummy password
  bool _obscureText = true; // For password visibility toggle
  UserRole _selectedRole = UserRole.penyetoer; // Default role for registration
  bool _agreedToTerms = false; // New state for agreement checkbox

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pendaftaran berhasil untuk ${user.name} sebagai ${user.role.label}!'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Use themed background color
      body: SingleChildScrollView( // Allow scrolling for smaller screens
        child: Column(
          children: [
            const PageHeader(title: 'Daftar', showBackButton: false), // Translated
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
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap', // Indonesian label
                      prefixIcon: const Icon(Icons.person, color: AppColors.dark), // Themed icon
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
                  const SizedBox(height: 16.0),
                  DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Daftar sebagai', // Indonesian label
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
                  const SizedBox(height: 16.0),
                  CheckboxListTile(
                    title: RichText(
                      text: TextSpan(
                        text: 'Saya menyetujui ',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                        children: [
                          TextSpan(
                            text: 'Ketentuan Layanan',
                            style: const TextStyle(color: AppColors.secondary, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.termsOfService,
                                  arguments: UserModel(id: 'guest', name: 'Guest', email: 'guest@example.com', role: UserRole.penyetoer),
                                );
                              },
                          ),
                          TextSpan(
                            text: ' dan ',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color), // Use theme's text color
                          ),
                          TextSpan(
                            text: 'Kebijakan Privasi',
                            style: const TextStyle(color: AppColors.secondary, decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.privacyPolicy,
                                  arguments: UserModel(id: 'guest', name: 'Guest', email: 'guest@example.com', role: UserRole.penyetoer),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                    value: _agreedToTerms,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _agreedToTerms = newValue ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agreedToTerms ? _register : null, // Disable if not agreed
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.login);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.dark,
                    ),
                    child: const Text('Sudah punya akun? Masuk di sini.'),
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
