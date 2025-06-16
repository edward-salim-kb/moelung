import 'package:flutter/material.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart';

class NotificationScreen extends StatelessWidget {
  final UserModel currentUser;

  const NotificationScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    // Dummy list of notifications
    final List<Map<String, String>> notifications = [
      {
        'title': 'New Recycling Event!',
        'message': 'Join our community clean-up drive this Saturday. Tap for details!',
        'time': '2 hours ago',
      },
      {
        'title': 'Points Update',
        'message': 'You earned 50 points for recycling plastic bottles. Keep up the great work!',
        'time': 'Yesterday',
      },
      {
        'title': 'Important Announcement',
        'message': 'Changes to waste collection schedule for your area. Please check the new timings.',
        'time': '3 days ago',
      },
      {
        'title': 'New Article Published',
        'message': 'Read our latest article on "Sustainable Living Tips".',
        'time': '1 week ago',
      },
    ];

    return AppShell(
      navIndex: -1, // No bottom nav item for notifications
      user: currentUser,
      body: Column(
        children: [
          const PageHeader(title: 'Notifications'),
          Expanded(
            child: notifications.isEmpty
                ? const Center(child: Text('No new notifications.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: Icon(Icons.notifications, color: AppColors.primary),
                          title: Text(
                            notification['title']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification['message']!),
                              const SizedBox(height: 4),
                              Text(
                                notification['time']!,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          onTap: () {
                            // TODO: Implement navigation to notification details or related content
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tapped on: ${notification['title']}')),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
