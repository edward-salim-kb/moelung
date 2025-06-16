import 'package:moelung_new/models/enums/trash_type.dart';

class KolektoerTrashEntry {
  final String id;
  final String kolektoerName;
  final DateTime dateAdded;
  final TrashType trashType;
  final double weight;
  final double priceEarned;

  KolektoerTrashEntry({
    required this.id,
    required this.kolektoerName,
    required this.dateAdded,
    required this.trashType,
    required this.weight,
    required this.priceEarned,
  });
}
