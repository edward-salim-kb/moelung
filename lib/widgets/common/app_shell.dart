import 'package:flutter/material.dart';
import 'package:moelung_new/models/index.dart';
import 'package:moelung_new/utils/role_utils.dart';
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/models/user_model.dart'; // Add this import for UserModel
import 'package:moelung_new/config/app_routes.dart'; // Import AppRoutes
import 'bottom_nav.dart';

class AppShell extends StatefulWidget {
  final int navIndex;
  final UserModel user;
  final Widget body;

  const AppShell({
    super.key,
    required this.navIndex,
    required this.user,
    required this.body,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIdx;

  @override
  void initState() {
    super.initState();
    _currentIdx = widget.navIndex;
  }

  void _onNavTap(int idx) {
    if (idx == _currentIdx) return;
    setState(() => _currentIdx = idx);

    switch (idx) {
      case 0:
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: widget.user,
        );
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/trash', arguments: widget.user);
        break;
      case 3:
        final route =
            isPenyetoer(widget.user.role) ? '/leaderboard' : '/home'; // Navigate to home, which will redirect to Kolektoer dashboard
        Navigator.pushReplacementNamed(context, route, arguments: widget.user);
        break;
      case 4:
        Navigator.pushReplacementNamed(
          context,
          '/profile',
          arguments: widget.user,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.map, arguments: widget.user);
        },
        backgroundColor: AppColors.accent, // Use accent green for FAB
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0), // Slightly rounded corners
        ), // Recycling icon with dark green color
        heroTag: 'map_fab_hero',
        child: const Icon(Icons.recycling, color: AppColors.dark), // Add a unique heroTag
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIdx,
        user: widget.user,
      ),
      body: widget.body,
    );
  }
}
