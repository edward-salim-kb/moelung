import 'package:flutter/material.dart';
import 'package:moelung_new/models/index.dart';
import 'package:moelung_new/utils/role_utils.dart';
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/config/app_routes.dart';
import 'package:moelung_new/models/user_model.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final UserModel user;

  const BottomNav({super.key, required this.currentIndex, required this.user});

  static Widget buildFab(BuildContext context, UserModel user) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.map, arguments: user);
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.map_outlined),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.primary, // Use primary green for BottomAppBar
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 8, // Add elevation for subtle shadow
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(context, icon: Icons.home_outlined, index: 0, tooltip: 'Beranda'),
            _item(context, icon: Icons.delete_outline, index: 1, tooltip: 'Sampah'),
            if (!isKolektoer(user.role)) const SizedBox(width: 48), // Only show SizedBox if not Kolektoer
            _item(
              context,
              icon:
                  isPenyetoer(user.role)
                      ? Icons.emoji_events_outlined
                      : Icons.dashboard_customize_outlined,
              index: 3,
              tooltip: isPenyetoer(user.role) ? 'Papan Peringkat' : 'Dasbor',
            ),
            _item(context, icon: Icons.person_outline, index: 4, tooltip: 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required int index,
    required String tooltip, // Add tooltip parameter
  }) {
    final bool active = index == currentIndex;
    return IconButton(
      tooltip: tooltip, // Assign tooltip
      onPressed: () {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home', arguments: user);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/trash', arguments: user);
            break;
          case 3:
            final route =
                isPenyetoer(user.role) ? AppRoutes.leaderboard : AppRoutes.dashboard; // Navigate to dashboard for Kolektoer
            Navigator.pushReplacementNamed(context, route, arguments: user);
            break;
          case 4:
            Navigator.pushReplacementNamed(
              context,
              '/profile',
              arguments: user,
            );
            break;
        }
      },
      icon: Icon(icon, color: active ? AppColors.dark : AppColors.background), // Active: darker green, Inactive: background
    );
  }
}
