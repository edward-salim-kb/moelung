import 'package:moelung_new/models/enums/trash_type.dart';

class TrashItem {
  final String id;
  final String name;
  final TrashCategory category;
  final TrashType type;
  final double weight;
  final DateTime createdAt;

  TrashItem({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.weight,
    required this.createdAt,
  });
}
