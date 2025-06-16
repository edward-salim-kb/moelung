import 'package:moelung_new/models/trash_item_model.dart';
import 'package:moelung_new/models/enums/trash_type.dart';
import 'package:moelung_new/models/user_model.dart';

class TrashService {
  static Future<Map<TrashType, List<TrashItem>>> fetchAllTrashByUser(
      UserModel user) async {
    // Simulate fetching data from a backend
    await Future.delayed(const Duration(milliseconds: 500));

    // More diverse and human-like dummy data for Penyetoer's trash
    return {
      TrashType.bottle: [
        TrashItem(
            id: 'trash_bottle_001',
            name: 'Botol Plastik Bekas Minuman',
            category: TrashCategory.inorganic,
            type: TrashType.bottle,
            weight: 0.7,
            createdAt: DateTime.now().subtract(const Duration(hours: 5))),
        TrashItem(
            id: 'trash_bottle_002',
            name: 'Botol Plastik Bekas Sabun',
            category: TrashCategory.inorganic,
            type: TrashType.bottle,
            weight: 0.9,
            createdAt: DateTime.now().subtract(const Duration(days: 2))),
      ],
      TrashType.foodScrap: [
        TrashItem(
            id: 'trash_food_001',
            name: 'Sisa Makanan Organik',
            category: TrashCategory.organic,
            type: TrashType.foodScrap,
            weight: 1.5,
            createdAt: DateTime.now().subtract(const Duration(hours: 1))),
        TrashItem(
            id: 'trash_food_002',
            name: 'Kulit Buah dan Sayur',
            category: TrashCategory.organic,
            type: TrashType.foodScrap,
            weight: 0.8,
            createdAt: DateTime.now().subtract(const Duration(days: 1))),
      ],
      TrashType.cardboard: [
        TrashItem(
            id: 'trash_card_001',
            name: 'Kardus Bekas Paket',
            category: TrashCategory.paper,
            type: TrashType.cardboard,
            weight: 2.1,
            createdAt: DateTime.now().subtract(const Duration(hours: 3))),
      ],
      TrashType.glass: [
        TrashItem(
            id: 'trash_glass_001',
            name: 'Botol Kaca Bekas Sirup',
            category: TrashCategory.inorganic,
            type: TrashType.glass,
            weight: 1.1,
            createdAt: DateTime.now().subtract(const Duration(days: 3))),
      ],
      TrashType.can: [
        TrashItem(
            id: 'trash_can_001',
            name: 'Kaleng Minuman',
            category: TrashCategory.inorganic,
            type: TrashType.can,
            weight: 0.3,
            createdAt: DateTime.now().subtract(const Duration(hours: 10))),
      ],
      TrashType.diaper: [
        TrashItem(
            id: 'trash_diaper_001',
            name: 'Popok Bekas',
            category: TrashCategory.residual,
            type: TrashType.diaper,
            weight: 0.6,
            createdAt: DateTime.now().subtract(const Duration(hours: 2))),
      ],
    };
  }

  static Future<List<TrashItem>> fetchTrashByCategoryForUser({
    required String userId,
    required TrashCategory category,
  }) async {
    // Simulate fetching data from a backend
    await Future.delayed(const Duration(milliseconds: 300));

    // Filter from the main dummy data based on category
    final allTrash = await fetchAllTrashByUser(UserModel(id: userId, name: 'Dummy', email: 'dummy@example.com')); // Dummy user for fetching all trash
    List<TrashItem> filteredList = [];
    allTrash.forEach((type, items) {
      for (var item in items) {
        if (item.category == category) {
          filteredList.add(item);
        }
      }
    });
    return filteredList;
  }
}
