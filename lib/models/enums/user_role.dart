enum UserRole {
  penyetoerKumpoelAdat(
    label: 'Penyetoer – Kumpoel (Adat)',
    description:
        'Pemulung tradisional yang mengumpulkan sampah secara mandiri.',
  ),
  penyetoerKumpoelModern(
    label: 'Penyetoer – Kumpoel (Modern)',
    description:
        'Pemulung modern yang memanfaatkan teknologi untuk mengumpulkan sampah.',
  ),
  penyetoerJempoet(
    label: 'Penyetoer – Jempoet (Rumah Tangga)',
    description: 'Rumah tangga yang menyetorkan sampah terpilah.',
  ),
  kolektoer(
    label: 'Kolektoer',
    description: 'Pihak yang menjemput / menampung sampah daur ulang.',
  );

  const UserRole({required this.label, required this.description});
  final String label;
  final String description;

  String get shortLabel => switch (this) {
    UserRole.penyetoerKumpoelAdat => 'Kumpoel Adat',
    UserRole.penyetoerKumpoelModern => 'Kumpoel Modern',
    UserRole.penyetoerJempoet => 'Jempoet',
    UserRole.kolektoer => 'Kolektoer',
  };
}
