import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart'; // Import LatLng
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/screens/penyetoer/kumpoel_jempoet_screen.dart'; // Import EquipmentItem

class KumpoelDrawer extends StatelessWidget {
  final double totalCollectedTrashWeight;
  final List<LatLng> userRoutePoints;
  final VoidCallback onStartKumpoel;
  final List<EquipmentItem> equipmentList; // Changed type to EquipmentItem
  final bool isMotorcycleBorrowed; // New parameter
  final VoidCallback onLogTrash; // New parameter
  final String elapsedTime; // New parameter

  const KumpoelDrawer({
    super.key,
    required this.totalCollectedTrashWeight,
    required this.userRoutePoints,
    required this.onStartKumpoel,
    required this.equipmentList, // Required
    required this.isMotorcycleBorrowed, // Required
    required this.onLogTrash, // Required
    required this.elapsedTime, // Required
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.2,
      maxChildSize: 0.6,
      builder:
          (_, controller) => Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.dark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: ListView(
              controller: controller,
              children: [
                const Center(
                  child: Text(
                    'Kumpoel Mode',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onStartKumpoel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Mulai Kumpoel'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onLogTrash,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Log Sampah'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Waktu Kumpoel: $elapsedTime', // Display elapsed time
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Sampah Terkumpul: ${totalCollectedTrashWeight.toStringAsFixed(2)} kg',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rute Dilewati: ${userRoutePoints.length > 1 ? 'Simulasi rute aktif...' : 'Belum ada rute.'}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  'Perlengkapan Moelung:',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...equipmentList.map((item) => Card( // Use Card for better styling
                  color: AppColors.darkGrey,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(item.icon, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          item.name,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
                const SizedBox(height: 8),
                Text(
                  'Pinjam Motor Moelung: ${isMotorcycleBorrowed ? 'Ya' : 'Tidak'}',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
    );
  }
}
