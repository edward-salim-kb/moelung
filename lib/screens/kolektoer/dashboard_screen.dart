import 'package:flutter/material.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart'; // Import PageHeader
import 'package:moelung_new/models/user_model.dart';

class DashboardScreen extends StatelessWidget {
  final UserModel currentUser;

  const DashboardScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 5, // Assuming a new index for dashboard
      user: currentUser,
      body: Column( // Use Column to stack header and content
        children: [
          const PageHeader(title: 'Dashboard'), // Add the PageHeader
          Expanded( // Wrap the rest of the content in Expanded
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Kolektoer Dashboard, ${currentUser.name}!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('This is the Kolektoer Dashboard. More features coming soon!'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
