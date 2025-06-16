import 'package:moelung_new/models/point_catalog_item.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/models/enums/point_catalog.dart';

class PointMarketService {
  static Future<List<PointCatalogItem>> fetchCatalog() async {
    // More diverse dummy data for Point Market
    return [
      PointCatalogItem(
        id: 'voucher_gopay_25k',
        name: 'Voucher GoPay Rp25.000',
        description: 'Tukarkan poin Anda dengan saldo GoPay senilai Rp25.000.',
        imagePath: 'lib/assets/point-items/gopay.png',
        costPoints: 250,
        quantity: 20,
        category: CatalogCategory.voucher,
      ),
      PointCatalogItem(
        id: 'voucher_tokopedia_50k',
        name: 'Voucher Diskon Tokopedia Rp50.000',
        description: 'Dapatkan diskon Rp50.000 untuk pembelian di Tokopedia.',
        imagePath: 'lib/assets/point-items/tokopedia.png',
        costPoints: 400,
        quantity: 15,
        category: CatalogCategory.voucher,
      ),
      PointCatalogItem(
        id: 'merchandise_tumbler',
        name: 'Tumbler Moelung Eksklusif',
        description: 'Tumbler ramah lingkungan dengan desain Moelung yang stylish.',
        imagePath: 'lib/assets/point-items/tumbler.png',
        costPoints: 300,
        quantity: 10,
        category: CatalogCategory.merchandise,
      ),
      PointCatalogItem(
        id: 'merchandise_totebag',
        name: 'Tas Belanja Kain Moelung',
        description: 'Tas belanja kain yang kuat dan dapat digunakan kembali.',
        imagePath: 'lib/assets/point-items/bag.png',
        costPoints: 150,
        quantity: 25,
        category: CatalogCategory.merchandise,
      ),
      PointCatalogItem(
        id: 'donation_tree',
        name: 'Donasi Penanaman Pohon',
        description: 'Sumbangkan poin Anda untuk mendukung program penanaman pohon.',
        imagePath: 'lib/assets/point-items/forest.png',
        costPoints: 100,
        quantity: 999, // Unlimited quantity for donation
        category: CatalogCategory.donation,
      ),
      PointCatalogItem(
        id: 'voucher_pulsa_10k',
        name: 'Voucher Pulsa Rp10.000',
        description: 'Isi ulang pulsa Anda dengan voucher senilai Rp10.000.',
        imagePath: 'lib/assets/point-items/voucher.png',
        costPoints: 120,
        quantity: 30,
        category: CatalogCategory.voucher,
      ),
      PointCatalogItem(
        id: 'merchandise_keychain',
        name: 'Gantungan Kunci Moelung',
        description: 'Gantungan kunci unik dengan logo Moelung.',
        imagePath: 'lib/assets/point-items/keychain.png',
        costPoints: 50,
        quantity: 50,
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
