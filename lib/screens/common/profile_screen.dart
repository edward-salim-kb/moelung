import 'package:flutter/material.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart'; // Import PageHeader
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/config/app_routes.dart'; // Import AppRoutes
// Import EditProfileScreen

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

  @override
  void initState() {
    super.initState();
    _user = widget.currentUser;
  }

  // Method to navigate to edit profile screen and update user data
  void _navigateToEditProfile() async {
    final updatedUser = await Navigator.of(context).pushNamed(
      AppRoutes.editProfile,
      arguments: _user,
    );

    if (updatedUser != null && updatedUser is UserModel) {
      setState(() {
        _user = updatedUser;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'), // Indonesian: Profile updated successfully
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
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
          const PageHeader(title: 'Profil Saya', showBackButton: false), // Indonesian: My Profile
          Expanded( // Wrap the rest of the content in Expanded
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(_user.avatarUrl ?? 'lib/assets/avatar.png'), // Use user's avatar or placeholder
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Profile Info Card
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildProfileInfoRow(
                              icon: Icons.person,
                              label: 'Nama', // Indonesian: Name
                              value: _user.name,
                            ),
                            const Divider(),
                            _buildProfileInfoRow(
                              icon: Icons.email,
                              label: 'Email',
                              value: _user.email,
                            ),
                            const Divider(),
                            _buildProfileInfoRow(
                              icon: Icons.badge, // Icon for role
                              label: 'Peran', // Indonesian: Role
                              value: _user.role.label, // Display user role label
                            ),
                            const Divider(),
                            _buildProfileInfoRow(
                              icon: Icons.star,
                              label: 'Poin', // Indonesian: Points
                              value: _user.points.toString(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Space between info and options cards

                    // Options Card
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildProfileOptionRow(
                              icon: Icons.edit,
                              label: 'Edit Profil',
                              onTap: _navigateToEditProfile,
                            ),
                            // Removed Dividers between options, relying on padding within _buildProfileOptionRow
                            _buildProfileOptionRow(
                              icon: Icons.settings,
                              label: 'Pengaturan Aksesibilitas',
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.accessibilitySettings,
                                  arguments: _user,
                                );
                              },
                            ),
                            _buildProfileOptionRow(
                              icon: Icons.description,
                              label: 'Ketentuan Layanan',
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.termsOfService,
                                  arguments: _user,
                                );
                              },
                            ),
                            _buildProfileOptionRow(
                              icon: Icons.privacy_tip,
                              label: 'Kebijakan Privasi',
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.privacyPolicy,
                                  arguments: _user,
                                );
                              },
                            ),
                            _buildProfileOptionRow(
                              icon: Icons.logout,
                              label: 'Keluar',
                              onTap: () {
                                // TODO: Implement actual logout logic (clear user session, etc.)
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.login,
                                  (route) => false,
                                );
                              },
                              isDestructive: true, // Apply red color for logout
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? AppColors.errorRed : AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.errorRed : AppColors.dark,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: isDestructive ? AppColors.errorRed : Colors.grey,
            ),
          ],
        ),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.3), // Light background for the field
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: const TextStyle(fontSize: 18, color: AppColors.dark), // Darker text for contrast
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
