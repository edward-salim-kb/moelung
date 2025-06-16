class LeaderboardEntry {
  final String id;
  final int rank;
  final String name;
  final int quantity;
  final String avatarUrl;
  final bool isYou;

  LeaderboardEntry({
    required this.id,
    required this.rank,
    required this.name,
    required this.quantity,
    required this.avatarUrl,
    this.isYou = false,
  });
}
