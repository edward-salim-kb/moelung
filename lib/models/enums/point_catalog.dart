enum CatalogCategory {
  voucher,
  merchandise,
  cash;

  String get label => switch (this) {
    CatalogCategory.voucher => 'Voucher',
    CatalogCategory.merchandise => 'Merchandise',
    CatalogCategory.cash => 'Cash',
  };
}
