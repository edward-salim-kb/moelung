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
  final double collectedTrashWeight; // New field for collected trash at this tikoem

  Tikoem({
    required this.name,
    required this.location,
    this.totalTrashWeight = 0.0,
    this.trashBreakdown = const {},
    this.nextPickupDate,
    this.capacity = 0.0,
    this.lastEmptiedDate,
    this.collectedTrashWeight = 0.0, // Initialize new field
  });

  Tikoem copyWith({
    String? name,
    LatLng? location,
    double? totalTrashWeight,
    Map<TrashType, double>? trashBreakdown,
    DateTime? nextPickupDate,
    double? capacity,
    DateTime? lastEmptiedDate,
    double? collectedTrashWeight,
  }) {
    return Tikoem(
      name: name ?? this.name,
      location: location ?? this.location,
      totalTrashWeight: totalTrashWeight ?? this.totalTrashWeight,
      trashBreakdown: trashBreakdown ?? this.trashBreakdown,
      nextPickupDate: nextPickupDate ?? this.nextPickupDate,
      capacity: capacity ?? this.capacity,
      lastEmptiedDate: lastEmptiedDate ?? this.lastEmptiedDate,
      collectedTrashWeight: collectedTrashWeight ?? this.collectedTrashWeight,
    );
  }
}
