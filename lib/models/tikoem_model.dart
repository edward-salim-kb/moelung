import 'package:latlong2/latlong.dart';
import 'package:moelung_new/models/enums/trash_type.dart';

class Tikoem {
  final String name;
  final LatLng location;
  final double totalTrashWeight;
  final Map<TrashType, double> trashBreakdown;
  final DateTime? nextPickupDate;
  final double capacity; // in kg
  final DateTime? lastEmptiedDate;

  Tikoem({
    required this.name,
    required this.location,
    this.totalTrashWeight = 0.0,
    this.trashBreakdown = const {},
    this.nextPickupDate,
    this.capacity = 0.0,
    this.lastEmptiedDate,
  });
}
