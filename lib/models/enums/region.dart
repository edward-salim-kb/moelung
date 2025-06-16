enum Region {
  diYogyakarta,
  dkiJakarta,
  jawaBarat;

  String get label {
    switch (this) {
      case Region.diYogyakarta:
        return 'DI Yogyakarta';
      case Region.dkiJakarta:
        return 'DKI Jakarta';
      case Region.jawaBarat:
        return 'Jawa Barat';
    }
  }

  static Region? fromLabel(String label) {
    switch (label.trim().toLowerCase()) {
      case 'di yogyakarta':
        return Region.diYogyakarta;
      case 'dki jakarta':
        return Region.dkiJakarta;
      case 'jawa barat':
        return Region.jawaBarat;
      default:
        return null;
    }
  }
}
