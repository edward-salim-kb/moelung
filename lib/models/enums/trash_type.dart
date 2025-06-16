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
  plasticBag, // Added
  electronic, // Added
  metal,      // Added
  textile,    // Added
  wood,       // Added
  rubber,     // Added
  other,      // Added
}

extension TrashCategoryX on TrashCategory {
  String get label => switch (this) {
    TrashCategory.organic => 'Organik',
    TrashCategory.inorganic => 'Anorganik',
    TrashCategory.residual => 'Residu',
    TrashCategory.hazardous => 'Bahan Berbahaya',
    TrashCategory.paper => 'Kertas',
  };

  String get description => switch (this) {
    TrashCategory.organic => 'Sisa makanan, daun – untuk kompos.',
    TrashCategory.inorganic => 'Plastik, kaleng, kaca – untuk daur ulang.',
    TrashCategory.residual => 'Popok, pembalut – ke TPA.',
    TrashCategory.hazardous => 'Baterai, bohlam – fasilitas B3 khusus.',
    TrashCategory.paper => 'Kertas kering & kardus – daur ulang terpisah.',
  };
}

extension TrashTypeX on TrashType {
  String get label => switch (this) {
    TrashType.foodScrap => 'Sisa Makanan',
    TrashType.leaf => 'Daun',
    TrashType.bottle => 'Botol',
    TrashType.can => 'Kaleng',
    TrashType.glass => 'Kaca',
    TrashType.diaper => 'Popok',
    TrashType.sanitaryPad => 'Pembalut',
    TrashType.battery => 'Baterai',
    TrashType.lightBulb => 'Bohlam',
    TrashType.cardboard => 'Kardus',
    TrashType.officePaper => 'Kertas Kantor',
    TrashType.plasticBag => 'Kantong Plastik', // Added
    TrashType.electronic => 'Elektronik',     // Added
    TrashType.metal => 'Logam',               // Added
    TrashType.textile => 'Tekstil',           // Added
    TrashType.wood => 'Kayu',                 // Added
    TrashType.rubber => 'Karet',              // Added
    TrashType.other => 'Lain-lain',           // Added
  };

  TrashCategory get category {
    switch (this) {
      case TrashType.foodScrap:
      case TrashType.leaf:
        return TrashCategory.organic;
      case TrashType.bottle:
      case TrashType.can:
      case TrashType.glass:
      case TrashType.plasticBag: // Added
      case TrashType.electronic: // Added
      case TrashType.metal:      // Added
      case TrashType.textile:    // Added
      case TrashType.wood:       // Added
      case TrashType.rubber:     // Added
        return TrashCategory.inorganic;
      case TrashType.diaper:
      case TrashType.sanitaryPad:
      case TrashType.other:      // Added
        return TrashCategory.residual;
      case TrashType.battery:
      case TrashType.lightBulb:
        return TrashCategory.hazardous;
      case TrashType.cardboard:
      case TrashType.officePaper:
        return TrashCategory.paper;
    }
  }
}
