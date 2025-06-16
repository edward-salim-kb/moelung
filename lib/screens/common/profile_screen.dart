import 'package:flutter/material.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart'; // Import PageHeader
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/utils/app_colors.dart';

// Dummy UserService for demonstration
class UserService {
  static Future<UserModel> updateUser(UserModel user, {String? name, String? email}) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    // Create a new UserModel with updated fields
    return user.copyWith(
      name: name ?? user.name,
      email: email ?? user.email,
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final UserModel currentUser;

  const ProfileScreen({super.key, required this.currentUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel _user;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _user = widget.currentUser;
    _nameController = TextEditingController(text: _user.name);
    _emailController = TextEditingController(text: _user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedUser = await UserService.updateUser(
        _user,
        name: _nameController.text,
        email: _emailController.text,
      );
      setState(() {
        _user = updatedUser;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 4, // Assuming this is the profile index
      user: _user, // Use the mutable _user state
      body: Column( // Use Column to stack header and content
        children: [
          const PageHeader(title: 'Profile'), // Add the PageHeader
          Expanded( // Wrap the rest of the content in Expanded
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage('lib/assets/avatar.png'), // Placeholder for user avatar
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      _buildProfileInfoRow(
                        icon: Icons.person,
                        label: 'Role',
                        value: _user.role.toString().split('.').last, // Display user role from mutable state
                      ),
                      const Divider(),
                      _buildProfileInfoRow(
                        icon: Icons.star,
                        label: 'Points',
                        value: _user.points.toString(), // Display points from mutable state
                      ),
                      const Divider(),
                      const SizedBox(height: 30),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Save Profile',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement actual logout logic (clear user session, etc.)
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login', // Navigate back to the login screen
                              (route) => false, // Remove all previous routes from the stack
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Use a different color for logout
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Text(
            '$label:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
