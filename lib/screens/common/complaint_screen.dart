import 'package:flutter/material.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart'; // Import PageHeader
import 'package:moelung_new/models/user_model.dart'; // Import UserModel
import 'package:moelung_new/models/enums/user_role.dart'; // Import UserRole

class ComplaintScreen extends StatelessWidget {
  const ComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a dummy UserModel for demonstration
    final dummyUser = UserModel(
      id: '123',
      name: 'Guest User',
      email: 'guest@example.com',
      role: UserRole.penyetoer, // Using a valid penyetoer role
      // Add other required fields for UserModel if any
    );

    return AppShell(
      navIndex: 0, // Assuming 0 is the index for home or a general screen
      user: dummyUser,
      body: Column( // Use Column to stack header and content
        children: [
          const PageHeader(title: 'Complaint Portal'), // Add the PageHeader
          Expanded( // Wrap the rest of the content in Expanded
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Complaint Portal',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Subject',
                      ),
                    ),
                    const SizedBox(height: 10),
                    const TextField(
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Handle complaint submission
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Complaint Submitted!')),
                        );
                      },
                      child: const Text('Submit Complaint'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back to previous screen
                      },
                      child: const Text('Back to Homepage'),
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
}
