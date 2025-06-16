import 'package:moelung_new/models/trash_item_model.dart';
import 'package:moelung_new/models/enums/trash_type.dart';
import 'package:moelung_new/models/user_model.dart';

class TrashService {
  static Future<Map<TrashType, List<TrashItem>>> fetchAllTrashByUser(
      UserModel user) async {
    // Dummy data for now
    return {
      TrashType.bottle: [
        TrashItem(
            id: '1',
            name: 'Plastic Bottle',
            category: TrashCategory.inorganic,
            type: TrashType.bottle,
            weight: 0.5,
            createdAt: DateTime.now().subtract(const Duration(days: 1))),
      ],
      TrashType.foodScrap: [
        TrashItem(
            id: '2',
            name: 'Food Scraps',
            category: TrashCategory.organic,
            type: TrashType.foodScrap,
            weight: 1.2,
            createdAt: DateTime.now()),
      ],
    };
  }

  static Future<List<TrashItem>> fetchTrashByCategoryForUser({
    required String userId,
    required TrashCategory category,
  }) async {
    // Dummy data for now
    return [
      TrashItem(
          id: '3',
          name: 'Dummy Item',
          category: category,
          type: TrashType.bottle,
          weight: 0.8,
          createdAt: DateTime.now()),
    ];
  }
}
