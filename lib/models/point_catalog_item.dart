import 'package:moelung_new/models/enums/point_catalog.dart';

class PointCatalogItem {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final int costPoints;
  final int quantity;
  final CatalogCategory category;

  PointCatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.costPoints,
    required this.quantity,
    required this.category,
  });
}
