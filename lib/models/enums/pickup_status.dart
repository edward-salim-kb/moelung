enum PickupStatus {
  requested('Permintaan Dibuat', 'Permintaan jempoet Anda telah berhasil dibuat.'),
  searchingCollector('Mencari Kolektoer', 'Kami sedang mencari Kolektoer terdekat untuk mengambil sampah Anda.'),
  collectorAssigned('Kolektoer Ditemukan', 'Seorang Kolektoer telah menerima permintaan Anda dan akan segera menuju lokasi.'),
  onTheWay('Kolektoer Menuju Lokasi', 'Kolektoer sedang dalam perjalanan ke lokasi Anda.'),
  arrived('Kolektoer Tiba', 'Kolektoer telah tiba di lokasi Anda.'),
  collecting('Pengumpulan Sampah', 'Kolektoer sedang mengumpulkan sampah Anda.'),
  validating('Validasi Sampah', 'Kolektoer sedang memvalidasi jenis dan berat sampah Anda.'),
  completed('Selesai', 'Sampah Anda telah berhasil dijemput dan poin/uang telah ditambahkan.'),
  cancelled('Dibatalkan', 'Permintaan jempoet Anda telah dibatalkan.');

  final String label;
  final String description;

  const PickupStatus(this.label, this.description);
}
