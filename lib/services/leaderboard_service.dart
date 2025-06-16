import 'package:moelung_new/models/leaderboard_entry_model.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/models/enums/region.dart';
import 'package:moelung_new/models/event_model.dart';

import 'dart:math';

class LeaderboardService {
  static List<LeaderboardEntry> loadEntries({
    required UserModel currentUser,
    Region? region,
  }) {
    final random = Random();
    final List<LeaderboardEntry> allGeneratedEntries = [];

    // List of diverse Indonesian avatar image paths
    final List<String> avatarPaths = List.generate(
      21, // From image.png to image copy 20.png
      (index) => index == 0
          ? 'lib/assets/avatars/image.png'
          : 'lib/assets/avatars/image copy ${index - 1}.png',
    );

    // Ensure currentUser has a region for testing regional leaderboard
    final testCurrentUser = currentUser.region == null
        ? currentUser.copyWith(region: Region.dkiJakarta) // Default to Jakarta for testing
        : currentUser;

    // Generate a larger pool of dummy users with various regions
    final List<String> indonesianNames = [
      'Budi Santoso', 'Siti Aminah', 'Joko Susilo', 'Dewi Lestari', 'Agus Salim',
      'Rina Wijaya', 'Fajar Nugroho', 'Kartika Putri', 'Eko Prasetyo', 'Nurul Huda',
      'Bayu Pratama', 'Indah Permata', 'Cahyo Utomo', 'Dian Kusuma', 'Gatot Subroto',
      'Hana Rahmawati', 'Irfan Hakim', 'Lina Marlina', 'Mochamad Iqbal', 'Nia Ramadhani',
      'Pandu Wijaya', 'Qoriatul Hasanah', 'Rizky Febian', 'Sinta Bella', 'Taufik Hidayat',
      'Umi Kulsum', 'Vina Panduwinata', 'Wayan Sudarta', 'Yuni Shara', 'Zulkifli Hasan',
      'Putri Ayu', 'Rudi Hartono', 'Sri Wahyuni', 'Teguh Santoso', 'Umar Bakri',
      'Wati Indah', 'Xavier Tan', 'Yanti Susanti', 'Zahra Fadhilah', 'Andi Permana',
      'Citra Kirana', 'Denny Cagur', 'Fitriani', 'Gilang Dirga', 'Happy Salma',
      'Ivan Gunawan', 'Jessica Iskandar', 'Kevin Sanjaya', 'Luna Maya',
    ];

    // Shuffle names to ensure uniqueness for dummy users
    indonesianNames.shuffle(random);

    final List<UserModel> dummyUsers = [];
    for (int i = 0; i < 50; i++) {
      final String name = indonesianNames[i % indonesianNames.length]; // Use shuffled names
      final String email = '${name.toLowerCase().replaceAll(' ', '.')}${random.nextInt(100)}@example.com';
      final assignedRegion = (i % 5 == 0 && testCurrentUser.region != null)
          ? testCurrentUser.region!
          : Region.values[random.nextInt(Region.values.length)];
      final String avatar = avatarPaths[random.nextInt(avatarPaths.length)];

      dummyUsers.add(UserModel(
        id: 'user_${i + 1}',
        name: name,
        email: email,
        points: 50 + random.nextInt(500), // Vary points
        region: assignedRegion,
        avatarUrl: avatar, // Assign a random avatar
      ));
    }

    // Ensure the current user (or testCurrentUser) is part of the dummy users, or add them if not
    if (!dummyUsers.any((u) => u.id == testCurrentUser.id)) {
      dummyUsers.add(testCurrentUser.copyWith(
        avatarUrl: testCurrentUser.avatarUrl ?? avatarPaths[random.nextInt(avatarPaths.length)],
      ));
    } else {
      // Update current user's points, region, and avatar if they were already in dummyUsers
      final index = dummyUsers.indexWhere((u) => u.id == testCurrentUser.id);
      dummyUsers[index] = testCurrentUser.copyWith(
        avatarUrl: testCurrentUser.avatarUrl ?? avatarPaths[random.nextInt(avatarPaths.length)],
      );
    }

    // Convert dummy users to leaderboard entries
    for (final user in dummyUsers) {
      allGeneratedEntries.add(
        LeaderboardEntry(
          id: user.id,
          rank: 0, // Will be re-ranked later
          name: user.name,
          quantity: user.points,
          avatarUrl: user.avatarUrl!, // Use the assigned avatar
          isYou: user.id == testCurrentUser.id,
        ),
      );
    }

    // Filter by region
    List<LeaderboardEntry> filteredEntries;
    if (region == null) {
      // Global leaderboard (Indonesia)
      filteredEntries = List.from(allGeneratedEntries);
    } else {
      // Regional leaderboard (Province)
      filteredEntries = allGeneratedEntries
          .where((entry) =>
              dummyUsers.firstWhere((u) => u.id == entry.id).region == region)
          .toList();
    }

    // Sort and re-rank
    filteredEntries.sort((a, b) => b.quantity.compareTo(a.quantity));
    for (int i = 0; i < filteredEntries.length; i++) {
      filteredEntries[i].rank = i + 1;
    }

    // Ensure current user is visible, even if not in top ranks
    if (!filteredEntries.any((entry) => entry.isYou)) {
      final currentUserEntry = allGeneratedEntries.firstWhere((entry) => entry.isYou);
      // If current user is not in the filtered list (e.g., wrong region), add them
      // This logic might need refinement based on actual UI requirements (e.g., showing user's rank even if outside top N)
      // For now, if they are not in the filtered list, we won't add them unless their region matches.
      // The current filtering logic already handles this.
    }

    return filteredEntries;
  }

  static Future<EventModel> fetchLeaderboardEvent() async {
    // Calculate remaining time until a fixed future date (e.g., end of next week)
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7)); // Start a week ago
    final endDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 7)); // End of next week
    final duration = endDate.difference(now);

    String remainingLabel;
    if (duration.inDays > 0) {
      remainingLabel = '${duration.inDays} days left';
    } else if (duration.inHours > 0) {
      remainingLabel = '${duration.inHours} hours left';
    } else {
      remainingLabel = 'Less than an hour left';
    }

    return EventModel(
      id: 'le_minerale_challenge',
      name: 'Le Minerale Bottle Challenge',
      description: 'Join the Le Minerale Bottle Challenge and help us collect plastic bottles to save the environment!',
      startDate: startDate,
      endDate: endDate,
      remainingLabel: remainingLabel,
      imageUrl: 'lib/assets/le-minerale-event.png',
    );
  }
}
