import 'package:moelung_new/models/notification_model.dart';
import 'package:moelung_new/models/enums/notification_type.dart';

class NotificationService {
  static final List<NotificationModel> _notifications = [
    // New dummy notification for Penyetoer, very recent
    NotificationModel(
      id: 'notif_009',
      userId: 'penyetoer_id_default', // For Budi Santoso
      type: NotificationType.info,
      title: 'Pembaruan Penting: Kebijakan Sampah Baru!',
      body: 'Pemerintah daerah telah mengeluarkan kebijakan baru terkait pengelolaan sampah. Pelajari selengkapnya untuk memaksimalkan pendapatan Anda!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)), // Very recent
      isRead: false,
      relatedEntityId: 'policy_update_001',
    ),
    // Dummy notifications
    NotificationModel(
      id: 'notif_001',
      userId: 'penyetoer_id_default', // Assuming this is Budi Santoso
      type: NotificationType.trashUpdate,
      title: 'Sampah Baru Ditambahkan!',
      body: 'Kolektoer Siti Rahayu telah menambahkan 2.5 kg botol plastik ke inventaris Anda.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      relatedEntityId: 'trash_bottle_001',
    ),
    NotificationModel(
      id: 'notif_002',
      userId: 'penyetoer_id_default',
      type: NotificationType.jempoetStatus,
      title: 'Permintaan Jempoet Diterima!',
      body: 'Permintaan jempoet Anda untuk 5.5 kg sampah telah diterima oleh Kolektoer.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      relatedEntityId: 'req_jakarta_001',
    ),
    NotificationModel(
      id: 'notif_003',
      userId: 'kolektoer_id_default', // Assuming this is Siti Rahayu
      type: NotificationType.jempoetStatus,
      title: 'Permintaan Jempoet Baru!',
      body: 'Penyetoer Budi Santoso telah mengajukan permintaan jempoet baru.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      relatedEntityId: 'req_jakarta_001',
    ),
    NotificationModel(
      id: 'notif_004',
      userId: 'penyetoer_id_default',
      type: NotificationType.reward,
      title: 'Selamat! Anda Mendapat Poin Bonus!',
      body: 'Anda mendapatkan 100 poin bonus karena berhasil mengumpulkan sampah organik lebih dari 5kg minggu ini.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: false,
      relatedEntityId: 'bonus_organic_week',
    ),
    NotificationModel(
      id: 'notif_005',
      userId: 'kolektoer_id_default',
      type: NotificationType.info,
      title: 'Pembaruan Jadwal Pengambilan',
      body: 'Ada perubahan jadwal pengambilan sampah di area Jakarta Selatan. Mohon periksa detailnya.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      relatedEntityId: 'schedule_update_jkt',
    ),
    NotificationModel(
      id: 'notif_006',
      userId: 'kolektoer_id_default',
      type: NotificationType.jempoetStatus,
      title: 'Permintaan Jempoet Baru Diterima!',
      body: 'Penyetoer Budi Santoso telah menerima permintaan jempoet Anda.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
      relatedEntityId: 'req_jakarta_002',
    ),
    NotificationModel(
      id: 'notif_007',
      userId: 'kolektoer_id_default',
      type: NotificationType.trashUpdate,
      title: 'Sampah Berhasil Dikumpulkan!',
      body: 'Anda berhasil mengumpulkan 3.2 kg sampah kertas dari Penyetoer Ani.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
      relatedEntityId: 'trash_paper_001',
    ),
    NotificationModel(
      id: 'notif_008',
      userId: 'kolektoer_id_default',
      type: NotificationType.reward,
      title: 'Poin Bonus Kolektoer!',
      body: 'Anda mendapatkan 50 poin bonus karena menyelesaikan 10 permintaan jempoet minggu ini.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: false,
      relatedEntityId: 'bonus_jempoet_week',
    ),
  ];

  static Future<List<NotificationModel>> fetchNotificationsByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    
    List<NotificationModel> userNotifications = _notifications.where((n) => n.userId == userId).toList();

    // Hardcode a prominent notification for 'penyetoer_id_default' if it's not already there
    if (userId == 'penyetoer_id_default' && !userNotifications.any((n) => n.id == 'hardcoded_penyetoer_notif')) {
      userNotifications.insert(0, NotificationModel(
        id: 'hardcoded_penyetoer_notif',
        userId: 'penyetoer_id_default',
        type: NotificationType.info,
        title: 'Selamat Datang di Moelung!',
        body: 'Ini adalah notifikasi percobaan untuk memastikan sistem notifikasi berfungsi dengan baik.',
        createdAt: DateTime.now().subtract(const Duration(seconds: 10)), // Very recent
        isRead: false,
        relatedEntityId: 'welcome_message',
      ));
    }

    userNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
    return userNotifications;
  }

  static Future<void> addNotification(NotificationModel notification) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    _notifications.add(notification);
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].markAsRead();
    }
  }
}
