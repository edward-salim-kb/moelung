import 'package:flutter/material.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart';
import 'package:moelung_new/services/notification_service.dart'; // Import NotificationService
import 'package:moelung_new/models/notification_model.dart'; // Import NotificationModel

class NotificationScreen extends StatefulWidget {
  final UserModel currentUser;

  const NotificationScreen({super.key, required this.currentUser});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final fetchedNotifications = await NotificationService.fetchNotificationsByUserId(widget.currentUser.id);
      setState(() {
        _notifications = fetchedNotifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load notifications: $e'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
    }
  }

  void _markAsRead(NotificationModel notification) async {
    setState(() {
      notification.isRead = true; // Optimistic update
    });
    await NotificationService.markNotificationAsRead(notification.id);
    // Optionally re-fetch or just update the local list
    _fetchNotifications(); // Re-fetch to ensure consistency
  }

  String _formatTimeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) {
      return '${diff.inDays} hari yang lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 0, // Show bottom nav item for notifications (e.g., home index)
      user: widget.currentUser,
      body: Column(
        children: [
          const PageHeader(title: 'Notifikasi', showBackButton: true), // Add back button
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _notifications.isEmpty
                    ? const Center(child: Text('Belum ada notifikasi baru.', style: TextStyle(color: AppColors.secondary)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _notifications.length,
                        separatorBuilder: (context, index) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            color: notification.isRead ? AppColors.background : Colors.white, // Differentiate read/unread
                            child: ListTile(
                              leading: Icon(
                                notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                                color: notification.isRead ? AppColors.secondary : AppColors.primary,
                              ),
                              title: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.body,
                                    style: TextStyle(color: notification.isRead ? Colors.grey : Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTimeAgo(notification.createdAt),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              onTap: () {
                                _markAsRead(notification);
                                // TODO: Implement navigation to notification details or related content based on notification.type and relatedEntityId
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Notifikasi sudah dibaca: ${notification.title}'),
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
          // Add SizedBox at the bottom to prevent FAB from blocking content
          SizedBox(height: kBottomNavigationBarHeight + 16.0),
        ],
      ),
    );
  }
}
