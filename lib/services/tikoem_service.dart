import 'package:moelung_new/models/tikoem_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:moelung_new/models/enums/trash_type.dart';

Future<List<Tikoem>> fetchTikoems() async {
  // Dummy data for now with trash statistics
  return [
    Tikoem(
      name: 'Tikoem Cilandak',
      location: LatLng(-6.36806, 106.82719),
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
      name: 'Tikoem Pasar Minggu',
      location: LatLng(-6.37000, 106.83000),
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
      name: 'Tikoem Jagakarsa',
      location: LatLng(-6.35000, 106.85000),
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
  ];
}
