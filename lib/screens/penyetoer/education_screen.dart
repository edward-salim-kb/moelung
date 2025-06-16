import 'package:flutter/material.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart'; // Import PageHeader
import 'package:moelung_new/models/user_model.dart';

class EducationScreen extends StatelessWidget {
  final UserModel currentUser;

  const EducationScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 6, // Assign a new index for education
      user: currentUser,
      body: Column( // Use Column to stack header and content
        children: [
          const PageHeader(title: 'Education & Guides'), // Add the PageHeader
          Expanded( // Wrap the rest of the content in Expanded
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to Education & Guides, ${currentUser.name}!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('Here you will find educational materials and quizzes.'),
                  // TODO: Add interactive educational content and quizzes
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
