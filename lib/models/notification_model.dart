import 'package:moelung_new/models/enums/notification_type.dart';

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;
  final String? relatedEntityId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.relatedEntityId,
  });

  // Method to mark notification as read
  void markAsRead() {
    isRead = true;
  }
}
