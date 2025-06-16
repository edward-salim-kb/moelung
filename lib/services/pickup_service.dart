import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:moelung_new/models/pickup_request_model.dart';
import 'package:moelung_new/models/enums/trash_type.dart';
import 'package:moelung_new/models/enums/pickup_status.dart';
import 'package:moelung_new/services/tikoem_service.dart'; // Import TikoemService
import 'dart:async';
import 'dart:math';
// Removed: import 'dart:convert';
// Removed: import 'package:http/http.dart' as http;

// Helper function to generate a random LatLng within a radius of a center point
LatLng _generateRandomLatLng(LatLng center, double radiusKm) {
  final random = Random();
  // Convert radius from km to degrees (approx 1 degree = 111 km)
  final double radiusDegrees = radiusKm / 111.0;

  // Generate random angle and distance
  final double u = random.nextDouble();
  final double v = random.nextDouble();
  final double w = radiusDegrees * sqrt(u);
  final double t = 2 * pi * v;
  final double x = w * cos(t);
  final double y = w * sin(t);

  // Adjust the x coordinate for the shrinking of the east-west distance
  final double newX = x / cos(center.latitude * pi / 180);

  final double foundLatitude = center.latitude + y;
  final double foundLongitude = center.longitude + newX;

  return LatLng(foundLatitude, foundLongitude);
}

// Removed: Uri _buildOsrmUri(LatLng from, LatLng to) { ... }

class PickupService extends ChangeNotifier {
  PickupRequest? _currentPickupRequest;
  Timer? _statusTimer;
  Timer? _locationSimulationTimer; // New timer for location updates
  final Distance _distance = const Distance(); // For distance calculation

  PickupRequest? get currentPickupRequest => _currentPickupRequest;

  // Simulate creating a pickup request and its lifecycle
  Future<void> createPickupRequest({
    required String penyetoerId,
    required String penyetoerName,
    required LatLng location,
    required String address,
    required double totalWeight,
    required Map<TrashType, double> trashBreakdown,
  }) async {
    _currentPickupRequest = PickupRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      penyetoerId: penyetoerId,
      penyetoerName: penyetoerName,
      location: location,
      address: address,
      totalWeight: totalWeight,
      trashBreakdown: trashBreakdown,
      requestedAt: DateTime.now(),
      status: PickupStatus.requested,
      statusHistory: [PickupStatus.requested],
    );
    notifyListeners();

    // Simulate status progression
    _statusTimer?.cancel();
    _locationSimulationTimer?.cancel(); // Cancel any existing location timer

    _statusTimer = Timer(const Duration(seconds: 3), () async {
      _updateStatus(PickupStatus.searchingCollector);
        _statusTimer = Timer(const Duration(seconds: 3), () async {
          final collectorName = _getRandomCollectorName();
          final tikoems = await fetchTikoems(userLocation: location); // Fetch dummy tikoems closer to user
          final collectorStartTikoem = tikoems[Random().nextInt(tikoems.length)]; // Pick a random tikoem as start
          
          _updateStatus(
            PickupStatus.collectorAssigned,
            collectorId: 'collector_${Random().nextInt(1000)}',
            collectorName: collectorName,
            collectorStartLocation: collectorStartTikoem.location,
            currentCollectorLocation: collectorStartTikoem.location, // Start at Tikoem
          );
        _statusTimer = Timer(const Duration(seconds: 3), () {
          _updateStatus(PickupStatus.onTheWay);
          _startLocationSimulation(); // Start simulating movement
          _statusTimer = Timer(const Duration(seconds: 15), () { // Give time for simulation
            _updateStatus(PickupStatus.arrived);
            _locationSimulationTimer?.cancel(); // Stop simulation
            _statusTimer = Timer(const Duration(seconds: 3), () {
              _updateStatus(PickupStatus.collecting);
              _statusTimer = Timer(const Duration(seconds: 3), () {
                _updateStatus(PickupStatus.validating);
                _statusTimer = Timer(const Duration(seconds: 3), () {
                  _updateStatus(PickupStatus.completed);
                  _statusTimer = null; // End of lifecycle
                });
              });
            });
          });
        });
      });
    });
  }

  void _updateStatus(
    PickupStatus newStatus, {
    String? collectorId,
    String? collectorName,
    LatLng? collectorStartLocation,
    LatLng? currentCollectorLocation,
    double? distanceRemaining,
    // Removed: List<LatLng>? routePoints,
  }) {
    if (_currentPickupRequest == null) return;

    final updatedHistory = List<PickupStatus>.from(_currentPickupRequest!.statusHistory);
    if (!updatedHistory.contains(newStatus)) {
      updatedHistory.add(newStatus);
    }

    _currentPickupRequest = _currentPickupRequest!.copyWith(
      status: newStatus,
      collectorId: collectorId ?? _currentPickupRequest!.collectorId,
      collectorName: collectorName ?? _currentPickupRequest!.collectorName,
      collectorStartLocation: collectorStartLocation ?? _currentPickupRequest!.collectorStartLocation,
      currentCollectorLocation: currentCollectorLocation ?? _currentPickupRequest!.currentCollectorLocation,
      distanceRemaining: distanceRemaining ?? _currentPickupRequest!.distanceRemaining,
      // Removed: routePoints: routePoints ?? _currentPickupRequest!.routePoints,
      statusHistory: updatedHistory,
    );
    notifyListeners();
  }

  Future<void> _startLocationSimulation() async {
    if (_currentPickupRequest == null || _currentPickupRequest!.currentCollectorLocation == null) return;

    final start = _currentPickupRequest!.currentCollectorLocation!;
    final end = _currentPickupRequest!.location;
    final totalDistance = _distance(start, end) / 1000; // in km

    int steps = 30; // Increased steps for smoother movement
    int currentStep = 0;

    _locationSimulationTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) { // Slightly longer interval
      if (currentStep >= steps) {
        timer.cancel();
        _updateStatus(
          _currentPickupRequest!.status,
          currentCollectorLocation: end,
          distanceRemaining: 0.0,
        );
        return;
      }

      currentStep++;
      final t = currentStep / steps; // Interpolation factor

      final newLat = start.latitude + (end.latitude - start.latitude) * t;
      final newLng = start.longitude + (end.longitude - start.longitude) * t;
      final newLocation = LatLng(newLat, newLng);

      final remaining = _distance(newLocation, end) / 1000; // in km

      _updateStatus(
        _currentPickupRequest!.status,
        currentCollectorLocation: newLocation,
        distanceRemaining: remaining,
      );
    });
  }

  void cancelPickupRequest() {
    if (_currentPickupRequest == null) return;
    _statusTimer?.cancel();
    _locationSimulationTimer?.cancel();
    _updateStatus(PickupStatus.cancelled);
  }

  void clearPickupRequest() {
    _statusTimer?.cancel();
    _locationSimulationTimer?.cancel();
    _currentPickupRequest = null;
    notifyListeners();
  }

  String _getRandomCollectorName() {
    final names = [
      'Pak Budi',
      'Bu Siti',
      'Mas Joko',
      'Mbak Dewi',
      'Kang Ujang',
      'Neng Ani',
    ];
    return names[Random().nextInt(names.length)];
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _locationSimulationTimer?.cancel();
    super.dispose();
  }

  // Dummy data for fetching all pickup requests (for Kolektoer side)
  static Future<List<PickupRequest>> fetchAllPickupRequestsForKolektoer({LatLng? userLocation}) async {
    await Future.delayed(const Duration(seconds: 1));
    final LatLng baseLocation = userLocation ?? LatLng(-6.36806, 106.82719); // Fallback to default if no user location

    return [
      PickupRequest(
        id: 'req_jakarta_001',
        penyetoerId: 'penyetoer_budi_jkt',
        penyetoerName: 'Budi Santoso',
        location: _generateRandomLatLng(baseLocation, 0.01), // 0.01 km radius (10 meters)
        address: 'Jl. Merdeka No. 10, Jakarta Pusat',
        totalWeight: 5.5,
        trashBreakdown: {
          TrashType.bottle: 2.5,
          TrashType.can: 0.5,
          TrashType.cardboard: 1.0,
          TrashType.officePaper: 1.0,
          TrashType.glass: 0.5,
        },
        requestedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: PickupStatus.requested,
      ),
      PickupRequest(
        id: 'req_bandung_002',
        penyetoerId: 'penyetoer_siti_bdg',
        penyetoerName: 'Siti Aminah',
        location: _generateRandomLatLng(baseLocation, 0.02), // 0.02 km radius (20 meters)
        address: 'Jl. Braga No. 20, Bandung',
        totalWeight: 10.0,
        trashBreakdown: {
          TrashType.foodScrap: 5.0,
          TrashType.leaf: 2.0,
          TrashType.bottle: 3.0,
        },
        requestedAt: DateTime.now().subtract(const Duration(days: 1)),
        status: PickupStatus.requested,
      ),
      PickupRequest(
        id: 'req_surabaya_003',
        penyetoerId: 'penyetoer_joko_sby',
        penyetoerName: 'Joko Susilo',
        location: _generateRandomLatLng(baseLocation, 0.03), // 0.03 km radius (30 meters)
        address: 'Jl. Pahlawan No. 5, Surabaya',
        totalWeight: 2.1,
        trashBreakdown: {
          TrashType.glass: 1.5,
          TrashType.cardboard: 0.3,
          TrashType.officePaper: 0.3,
        },
        requestedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        status: PickupStatus.requested,
      ),
    ];
  }
}
