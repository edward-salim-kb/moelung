import 'package:moelung_new/models/enums/user_role.dart';

import 'package:moelung_new/models/enums/region.dart'; // Import Region enum

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final int points;
  final Region? region; // Add region property
  final String? avatarUrl; // Add avatarUrl property

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.penyetoer,
    this.points = 0,
    this.region, // Make region optional for now
    this.avatarUrl, // Add avatarUrl to constructor
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    int? points,
    Region? region,
    String? avatarUrl, // Add avatarUrl to copyWith
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      points: points ?? this.points,
      region: region ?? this.region,
      avatarUrl: avatarUrl ?? this.avatarUrl, // Update avatarUrl in copyWith
    );
  }
}
