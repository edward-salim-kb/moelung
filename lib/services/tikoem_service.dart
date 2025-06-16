import 'dart:math';
import 'package:moelung_new/models/tikoem_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:moelung_new/models/enums/trash_type.dart';

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

class HistoricalRoute {
  final List<LatLng> points;
  final DateTime walkedAt;

  HistoricalRoute({required this.points, required this.walkedAt});
}

// Helper function to generate a jagged path between two points
List<LatLng> _generateJaggedPath(LatLng start, LatLng end, int segments, double windingFactor) {
  List<LatLng> path = [start];
  for (int i = 1; i <= segments; i++) {
    double t = i / segments;
    double lat = start.latitude + (end.latitude - start.latitude) * t;
    double lng = start.longitude + (end.longitude - start.longitude) * t;

    // Add a random offset to simulate jaggedness
    double offsetLat = (Random().nextDouble() - 0.5) * windingFactor;
    double offsetLng = (Random().nextDouble() - 0.5) * windingFactor;

    path.add(LatLng(lat + offsetLat, lng + offsetLng));
  }
  return path;
}

Future<List<Tikoem>> fetchTikoems({LatLng? userLocation}) async {
  final LatLng baseLocation = userLocation ?? LatLng(-6.36806, 106.82719); // Fallback to default if no user location

  // Generate dummy data relative to the user's location
  return [
    Tikoem(
      name: 'Tikoem 1 (1km)',
      location: _generateRandomLatLng(baseLocation, 1.0), // 1 km radius
      totalTrashWeight: 1500.0, // kg
      trashBreakdown: {
        TrashType.bottle: 500.0,
        TrashType.can: 200.0,
        TrashType.cardboard: 300.0,
        TrashType.officePaper: 100.0,
        TrashType.glass: 100.0,
        TrashType.foodScrap: 100.0,
      },
      nextPickupDate: DateTime.now().add(const Duration(days: 3)),
      capacity: 2000.0, // kg
      lastEmptiedDate: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Tikoem(
      name: 'Tikoem 2 (2km)',
      location: _generateRandomLatLng(baseLocation, 2.0), // 2 km radius
      totalTrashWeight: 2200.0, // kg
      trashBreakdown: {
        TrashType.bottle: 700.0,
        TrashType.can: 300.0,
        TrashType.cardboard: 400.0,
        TrashType.officePaper: 200.0,
        TrashType.glass: 150.0,
        TrashType.foodScrap: 150.0,
      },
      nextPickupDate: DateTime.now().add(const Duration(days: 1)),
      capacity: 3000.0, // kg
      lastEmptiedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Tikoem(
      name: 'Tikoem 3 (3km)',
      location: _generateRandomLatLng(baseLocation, 3.0), // 3 km radius
      totalTrashWeight: 900.0, // kg
      trashBreakdown: {
        TrashType.bottle: 300.0,
        TrashType.can: 100.0,
        TrashType.cardboard: 150.0,
        TrashType.officePaper: 100.0,
        TrashType.glass: 50.0,
        TrashType.foodScrap: 50.0,
      },
      nextPickupDate: DateTime.now().add(const Duration(days: 5)),
      capacity: 1000.0, // kg
      lastEmptiedDate: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Tikoem(
      name: 'Tikoem 4 (4km)',
      location: _generateRandomLatLng(baseLocation, 4.0), // 4 km radius
      totalTrashWeight: 1200.0, // kg
      trashBreakdown: {
        TrashType.bottle: 400.0,
        TrashType.can: 150.0,
        TrashType.cardboard: 200.0,
        TrashType.officePaper: 100.0,
        TrashType.glass: 100.0,
        TrashType.foodScrap: 100.0,
      },
      nextPickupDate: DateTime.now().add(const Duration(days: 2)),
      capacity: 1500.0, // kg
      lastEmptiedDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
}

// Dummy data for historical routes
Future<List<HistoricalRoute>> fetchDummyHistoricalRoutes({LatLng? userLocation}) async {
  await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
  final LatLng baseLocation = userLocation ?? LatLng(-6.36806, 106.82719); // Fallback to default

  List<HistoricalRoute> routes = [];
  final random = Random();

  // Route 1: Short jagged path, walked recently
  LatLng start1 = _generateRandomLatLng(baseLocation, 0.5);
  LatLng end1 = _generateRandomLatLng(baseLocation, 0.8);
  routes.add(HistoricalRoute(
    points: _generateJaggedPath(start1, end1, 10, 0.0008), // Increased windingFactor
    walkedAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
  ));

  // Route 2: Another short jagged path, walked a bit longer ago
  LatLng start2 = _generateRandomLatLng(baseLocation, 1.0);
  LatLng end2 = _generateRandomLatLng(baseLocation, 1.3);
  routes.add(HistoricalRoute(
    points: _generateJaggedPath(start2, end2, 12, 0.001), // Increased windingFactor
    walkedAt: DateTime.now().subtract(const Duration(days: 3, hours: 10)),
  ));

  // Route 3: A slightly longer, but still jagged path, walked even longer ago
  LatLng start3 = _generateRandomLatLng(baseLocation, 1.5);
  LatLng end3 = _generateRandomLatLng(baseLocation, 2.0);
  routes.add(HistoricalRoute(
    points: _generateJaggedPath(start3, end3, 15, 0.0012), // Increased windingFactor
    walkedAt: DateTime.now().subtract(const Duration(days: 7, hours: 2)),
  ));

  return routes;
}

// Dummy trash pricing data (per kg)
const Map<TrashType, double> trashPrices = {
  TrashType.bottle: 2500.0, // IDR per kg
  TrashType.can: 3000.0,
  TrashType.cardboard: 1500.0,
  TrashType.officePaper: 1800.0,
  TrashType.glass: 1000.0,
  TrashType.foodScrap: 500.0,
  TrashType.leaf: 400.0,
  TrashType.plasticBag: 800.0,
  TrashType.diaper: 200.0,
  TrashType.electronic: 5000.0,
  TrashType.metal: 4000.0,
  TrashType.textile: 700.0,
  TrashType.wood: 600.0,
  TrashType.rubber: 900.0,
  TrashType.other: 500.0,
};

double estimateTrashPrice(Map<TrashType, double> trashBreakdown) {
  double totalPrice = 0.0;
  trashBreakdown.forEach((type, weight) {
    totalPrice += (trashPrices[type] ?? 0.0) * weight;
  });
  return totalPrice;
}
