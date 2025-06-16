import 'package:moelung_new/models/point_catalog_item.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/models/enums/point_catalog.dart';

class PointMarketService {
  static Future<List<PointCatalogItem>> fetchCatalog() async {
    // Dummy data for now
    return [
      PointCatalogItem(
        id: '1',
        name: 'Voucher 10k',
        description: 'Discount voucher for 10,000 IDR',
        imagePath: 'lib/assets/edu1.png', // Dummy image path
        costPoints: 100,
        quantity: 10,
        category: CatalogCategory.voucher,
      ),
      PointCatalogItem(
        id: '2',
        name: 'T-Shirt',
        description: 'Cool Moelung T-Shirt',
        imagePath: 'lib/assets/edu1.png', // Dummy image path
        costPoints: 500,
        quantity: 5,
        category: CatalogCategory.merchandise,
      ),
    ];
  }

  static Future<UserModel> redeemItem({
    required UserModel user,
    required String itemId,
    required int cost,
  }) async {
    // Simulate redemption
    if (user.points >= cost) {
      // In a real app, this would interact with a backend
      return UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        points: user.points - cost, // Deduct points
      );
    } else {
      throw Exception('Not enough points to redeem this item.');
    }
  }
}
