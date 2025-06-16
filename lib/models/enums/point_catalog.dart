enum CatalogCategory {
  voucher,
  merchandise,
  cash,
  donation; // Add donation category

  String get label => switch (this) {
    CatalogCategory.voucher => 'Voucher',
    CatalogCategory.merchandise => 'Merchandise',
    CatalogCategory.cash => 'Cash',
    CatalogCategory.donation => 'Donasi', // Add label for donation
  };
}
