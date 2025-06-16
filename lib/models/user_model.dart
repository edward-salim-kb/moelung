import 'package:moelung_new/models/enums/user_role.dart';

import 'package:moelung_new/models/enums/user_role.dart';
import 'package:moelung_new/models/enums/region.dart'; // Import Region enum

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final int points;
  final Region? region; // Add region property

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.penyetoerJempoet,
    this.points = 0,
    this.region, // Make region optional for now
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    int? points,
    Region? region,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      points: points ?? this.points,
      region: region ?? this.region,
    );
  }
}
