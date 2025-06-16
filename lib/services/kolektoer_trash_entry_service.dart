import 'package:moelung_new/models/kolektoer_trash_entry_model.dart';
import 'package:moelung_new/models/enums/trash_type.dart';

class KolektoerTrashEntryService {
  // Dummy pricing per kg for each trash type (in Rupiah) - duplicated for now, should be centralized
  static final Map<TrashType, double> _pricingPerKg = {
    TrashType.foodScrap: 500.0,
    TrashType.leaf: 300.0,
    TrashType.bottle: 1500.0,
    TrashType.can: 1200.0,
    TrashType.glass: 800.0,
    TrashType.diaper: 100.0,
    TrashType.sanitaryPad: 100.0,
    TrashType.battery: 5000.0,
    TrashType.lightBulb: 2000.0,
    TrashType.cardboard: 700.0,
    TrashType.officePaper: 900.0,
  };

  static Future<List<KolektoerTrashEntry>> fetchKolektoerTrashEntries(String userId) async {
    // Simulate fetching data from a backend
    await Future.delayed(const Duration(milliseconds: 700));

    // Dummy data for Kolektoer added trash entries for a specific user
    // In a real application, this would be filtered by the actual userId
    return [
      KolektoerTrashEntry(
        id: 'kolektoer_entry_001',
        kolektoerName: 'Budi Kolektoer',
        dateAdded: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        trashType: TrashType.bottle,
        weight: 1.2,
        priceEarned: 1.2 * (_pricingPerKg[TrashType.bottle] ?? 0.0),
      ),
      KolektoerTrashEntry(
        id: 'kolektoer_entry_002',
        kolektoerName: 'Ani Kolektoer',
        dateAdded: DateTime.now().subtract(const Duration(days: 3, hours: 10)),
        trashType: TrashType.foodScrap,
        weight: 2.5,
        priceEarned: 2.5 * (_pricingPerKg[TrashType.foodScrap] ?? 0.0),
      ),
      KolektoerTrashEntry(
        id: 'kolektoer_entry_003',
        kolektoerName: 'Budi Kolektoer',
        dateAdded: DateTime.now().subtract(const Duration(days: 5, hours: 1)),
        trashType: TrashType.cardboard,
        weight: 3.0,
        priceEarned: 3.0 * (_pricingPerKg[TrashType.cardboard] ?? 0.0),
      ),
      KolektoerTrashEntry(
        id: 'kolektoer_entry_004',
        kolektoerName: 'Cici Kolektoer',
        dateAdded: DateTime.now().subtract(const Duration(days: 7, hours: 2)),
        trashType: TrashType.can,
        weight: 0.8,
        priceEarned: 0.8 * (_pricingPerKg[TrashType.can] ?? 0.0),
      ),
    ];
  }
}
