enum UserRole {
  penyetoer(
    label: 'Penyetoer',
    description: 'Pengguna yang menyetorkan sampah.',
  ),
  kolektoer(
    label: 'Kolektoer',
    description: 'Pihak yang menjemput / menampung sampah daur ulang, memantau aktivitas, dan laporan.',
  );

  const UserRole({required this.label, required this.description});
  final String label;
  final String description;

  String get shortLabel => switch (this) {
    UserRole.penyetoer => 'Penyetoer',
    UserRole.kolektoer => 'Kolektoer',
  };
}
