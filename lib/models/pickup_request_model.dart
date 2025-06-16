import 'package:latlong2/latlong.dart';
import 'package:moelung_new/models/enums/trash_type.dart';
import 'package:moelung_new/models/enums/pickup_status.dart';

class PickupRequest {
  final String id;
  final String penyetoerId;
  final String penyetoerName;
  final LatLng location;
  final String address;
  final double totalWeight;
  final Map<TrashType, double> trashBreakdown;
  final DateTime requestedAt;
  final PickupStatus status;
  final String? collectorId;
  final String? collectorName;
  final LatLng? collectorStartLocation; // New: Kolektoer's starting Tikoem location
  final LatLng? currentCollectorLocation; // New: Kolektoer's current simulated location
  final double? distanceRemaining; // New: Remaining distance to user
  final List<PickupStatus> statusHistory; // New: to track timeline

  PickupRequest({
    required this.id,
    required this.penyetoerId,
    required this.penyetoerName,
    required this.location,
    required this.address,
    required this.totalWeight,
    required this.trashBreakdown,
    required this.requestedAt,
    this.status = PickupStatus.requested, // Changed default status
    this.collectorId,
    this.collectorName,
    this.collectorStartLocation, // Add to constructor
    this.currentCollectorLocation, // Add to constructor
    this.distanceRemaining, // Add to constructor
    List<PickupStatus>? statusHistory, // Initialize status history
  }) : statusHistory = statusHistory ?? [PickupStatus.requested];

  PickupRequest copyWith({
    String? id,
    String? penyetoerId,
    String? penyetoerName,
    LatLng? location,
    String? address,
    double? totalWeight,
    Map<TrashType, double>? trashBreakdown,
    DateTime? requestedAt,
    PickupStatus? status,
    String? collectorId,
    String? collectorName,
    LatLng? collectorStartLocation, // Add to copyWith
    LatLng? currentCollectorLocation, // Add to copyWith
    double? distanceRemaining, // Add to copyWith
    List<PickupStatus>? statusHistory,
  }) {
    return PickupRequest(
      id: id ?? this.id,
      penyetoerId: penyetoerId ?? this.penyetoerId,
      penyetoerName: penyetoerName ?? this.penyetoerName,
      location: location ?? this.location,
      address: address ?? this.address,
      totalWeight: totalWeight ?? this.totalWeight,
      trashBreakdown: trashBreakdown ?? this.trashBreakdown,
      requestedAt: requestedAt ?? this.requestedAt,
      status: status ?? this.status,
      collectorId: collectorId ?? this.collectorId,
      collectorName: collectorName ?? this.collectorName,
      collectorStartLocation: collectorStartLocation ?? this.collectorStartLocation, // Update
      currentCollectorLocation: currentCollectorLocation ?? this.currentCollectorLocation, // Update
      distanceRemaining: distanceRemaining ?? this.distanceRemaining, // Update
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}
