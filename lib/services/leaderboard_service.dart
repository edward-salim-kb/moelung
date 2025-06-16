import 'package:moelung_new/models/leaderboard_entry_model.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/models/enums/region.dart';
import 'package:moelung_new/models/event_model.dart';

class LeaderboardService {
  static List<LeaderboardEntry> loadEntries({
    required UserModel currentUser,
    Region? region,
  }) {
    // Dummy data for now
    return [
      LeaderboardEntry(
        id: '1',
        rank: 1,
        name: 'John Doe',
        quantity: 100,
        avatarUrl: 'https://via.placeholder.com/150',
        isYou: false,
      ),
      LeaderboardEntry(
        id: currentUser.id,
        rank: 2,
        name: currentUser.name,
        quantity: 90,
        avatarUrl: 'https://via.placeholder.com/150',
        isYou: true,
      ),
      LeaderboardEntry(
        id: '3',
        rank: 3,
        name: 'Jane Smith',
        quantity: 80,
        avatarUrl: 'https://via.placeholder.com/150',
        isYou: false,
      ),
    ];
  }

  static Future<EventModel> fetchLeaderboardEvent() async {
    // Dummy data for now
    return EventModel(
      id: 'event_1',
      name: 'Weekly Challenge',
      remainingLabel: '2 days left',
    );
  }
}
