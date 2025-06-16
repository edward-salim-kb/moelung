enum TrashCategory { organic, inorganic, residual, hazardous, paper }

enum TrashType {
  foodScrap,
  leaf,
  bottle,
  can,
  glass,
  diaper,
  sanitaryPad,
  battery,
  lightBulb,
  cardboard,
  officePaper,
}

extension TrashCategoryX on TrashCategory {
  String get label => switch (this) {
    TrashCategory.organic => 'Organic',
    TrashCategory.inorganic => 'Inorganic',
    TrashCategory.residual => 'Residual',
    TrashCategory.hazardous => 'Hazardous',
    TrashCategory.paper => 'Paper',
  };

  String get description => switch (this) {
    TrashCategory.organic => 'Food scraps, leaves – for compost.',
    TrashCategory.inorganic => 'Plastic, cans, glass – for recycling.',
    TrashCategory.residual => 'Diapers, sanitary pads – land‑fill.',
    TrashCategory.hazardous => 'Batteries, bulbs – special B3 facility.',
    TrashCategory.paper => 'Dry paper & cardboard – separate recycle.',
  };
}

extension TrashTypeX on TrashType {
  String get label => name
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .replaceFirst(name[0], name[0].toUpperCase());
}
