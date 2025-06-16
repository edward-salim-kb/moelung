import 'package:flutter/material.dart';
import 'package:moelung_new/models/index.dart';
import 'package:moelung_new/utils/role_utils.dart';
import 'package:moelung_new/utils/app_colors.dart';
// Add this import for UserModel
import 'package:moelung_new/config/app_routes.dart'; // Import AppRoutes
// Import ServiceType
// Import KumpoelJempoetScreen
// Import JempoetRequestScreen (will create next)
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
      floatingActionButton: widget.navIndex != -1 && !isKolektoer(widget.user.role)
          ? FloatingActionButton(
              onPressed: () => _showModeSelection(context), // Show mode selection
              backgroundColor: AppColors.accent, // Use accent green for FAB
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // Slightly rounded corners
              ), // Recycling icon with dark green color
              heroTag: 'map_fab_hero',
              child: const Icon(Icons.recycling, color: AppColors.dark), // Add a unique heroTag
            )
          : null, // Hide FAB if navIndex is -1 or user is Kolektoer
      bottomNavigationBar: widget.navIndex != -1
          ? BottomNav(
              currentIndex: _currentIdx,
              user: widget.user,
            )
          : null, // Hide BottomNav if navIndex is -1
      body: widget.body,
    );
  }

  void _showModeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true, // Allow dismissing
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih jenis layanan', // Indonesian: Choose service type
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _optionTile(
              context,
              ServiceType.jempoet,
              'Jempoet (Dijemput Kolektoer)', // Indonesian: Picked up by Kolektoer
              Icons.delivery_dining,
            ),
            const SizedBox(height: 12),
            _optionTile(
              context,
              ServiceType.kumpoel,
              'Kumpoel (Setor Sendiri)', // Indonesian: Drop off yourself
              Icons.shopping_bag,
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(BuildContext context, ServiceType type, String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).pop(); // Close the modal
        if (type == ServiceType.jempoet) {
          Navigator.pushNamed(context, AppRoutes.jempoetRequest, arguments: widget.user);
        } else {
          Navigator.pushNamed(
            context,
            AppRoutes.kumpoelJempoet,
            arguments: {
              'currentUser': widget.user,
              'initialServiceType': ServiceType.kumpoel,
            },
          );
        }
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: AppColors.primary, // Themed button color
        foregroundColor: Colors.white, // White text/icon
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
