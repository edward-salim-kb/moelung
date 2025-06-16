import 'package:flutter/material.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart';
import 'package:moelung_new/models/enums/trash_type.dart'; // Import TrashType
import 'package:moelung_new/utils/app_colors.dart'; // Import AppColors
import 'package:moelung_new/services/notification_service.dart'; // Import NotificationService
import 'package:moelung_new/models/notification_model.dart'; // Import NotificationModel
import 'package:moelung_new/models/enums/notification_type.dart'; // Import NotificationType

import 'dart:io'; // Import for File

class KolektoerTrashScreen extends StatefulWidget {
  final UserModel currentUser;

  const KolektoerTrashScreen({super.key, required this.currentUser});

  @override
  State<KolektoerTrashScreen> createState() => _KolektoerTrashScreenState();
}

class _KolektoerTrashScreenState extends State<KolektoerTrashScreen> {
  File? _imageFile;
  final TextEditingController _incidentController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();

  TrashType? _selectedTrashType;
  final TextEditingController _currentWeightController = TextEditingController();
  final List<MapEntry<TrashType, double>> _addedTrashItems = [];
  double _totalPrice = 0.0;

  // Dummy pricing per kg for each trash type
  final Map<TrashType, double> _pricingPerKg = {
    TrashType.foodScrap: 500.0,
    TrashType.leaf: 300.0,
    TrashType.bottle: 1500.0,
    TrashType.can: 1200.0,
    TrashType.glass: 800.0,
    TrashType.diaper: 100.0,
    TrashType.sanitaryPad: 100.0,
    TrashType.battery: 5000.0,
    TrashType.lightBulb: 2000.0,
    TrashType.cardboard: 700.0,
    TrashType.officePaper: 900.0,
  };

  @override
  void initState() {
    super.initState();
    _currentWeightController.addListener(_calculateTotalPrice);
  }

  void _pickImage() {
    // Dummy implementation for image picking
    setState(() {
      _imageFile = File('lib/assets/trash.png'); // Placeholder image
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gambar dipilih! (Aksi dummy)'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
      ),
    );
  }

  void _addTrashItem() {
    if (_selectedTrashType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih jenis sampah.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
      return;
    }
    final double weight = double.tryParse(_currentWeightController.text) ?? 0.0;
    if (weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon masukkan berat yang valid (> 0).'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
      return;
    }

    setState(() {
      // Check if the trash type already exists, if so, update its weight
      final existingIndex = _addedTrashItems.indexWhere((item) => item.key == _selectedTrashType);
      if (existingIndex != -1) {
        _addedTrashItems[existingIndex] = MapEntry(_selectedTrashType!, _addedTrashItems[existingIndex].value + weight);
      } else {
        _addedTrashItems.add(MapEntry(_selectedTrashType!, weight));
      }
      _selectedTrashType = null;
      _currentWeightController.clear();
      _calculateTotalPrice();
    });
  }

  void _removeTrashItem(TrashType type) {
    setState(() {
      _addedTrashItems.removeWhere((item) => item.key == type);
      _calculateTotalPrice();
    });
  }

  void _calculateTotalPrice() {
    double calculatedPrice = 0.0;
    for (var item in _addedTrashItems) {
      calculatedPrice += item.value * (_pricingPerKg[item.key] ?? 0.0);
    }
    setState(() {
      _totalPrice = calculatedPrice;
    });
  }

  Future<void> _submitTrashData() async {
    final String userEmail = _userEmailController.text;
    if (userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon masukkan Email/ID Penyetoer.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
      return;
    }

    if (_addedTrashItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon tambahkan setidaknya satu item sampah.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
      return;
    }

    double totalWeight = _addedTrashItems.fold(0.0, (sum, item) => sum + item.value);

    String trashDetails = _addedTrashItems
        .map((entry) => '${entry.key.label}: ${entry.value.toStringAsFixed(1)} kg')
        .join(', ');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pengiriman Sampah Berhasil!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Sampah dikirim untuk: $userEmail'),
                const SizedBox(height: 10),
                Text('Total Berat: ${totalWeight.toStringAsFixed(1)} kg'),
                const SizedBox(height: 10),
                Text('Detail: $trashDetails'),
                const SizedBox(height: 10),
                Text(
                  'Total Harga untuk Penyetoer: Rp${_totalPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Oke'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Add notification for the Penyetoer
    final notification = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'penyetoer_id_default', // Assuming this is the Penyetoer's ID
      type: NotificationType.trashUpdate,
      title: 'Sampah Anda Telah Dicatat!',
      body: 'Kolektoer ${widget.currentUser.name} telah mencatat ${totalWeight.toStringAsFixed(1)} kg sampah Anda. Detail: $trashDetails. Total harga: Rp${_totalPrice.toStringAsFixed(0)}.',
      createdAt: DateTime.now(),
      isRead: false,
      relatedEntityId: userEmail, // Use email as related ID for now
    );
    await NotificationService.addNotification(notification);

    // Clear inputs after submission
    _userEmailController.clear();
    _currentWeightController.clear();
    setState(() {
      _addedTrashItems.clear();
      _totalPrice = 0.0;
      _imageFile = null;
    });
  }

  void _reportIncident() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Insiden dilaporkan: ${_incidentController.text} (Aksi dummy)'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
      ),
    );
    _incidentController.clear();
  }

  @override
  void dispose() {
    _incidentController.dispose();
    _userEmailController.dispose();
    _currentWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 1, // Assuming 1 is the index for trash
      user: widget.currentUser,
      body: Column(
        children: [
          const PageHeader(title: 'Input Sampah Kolektoer', showBackButton: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang, ${widget.currentUser.name}!',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Masukkan detail sampah yang dikumpulkan dari Penyetoer.',
                    style: TextStyle(fontSize: 16, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _userEmailController,
                    decoration: InputDecoration(
                      labelText: 'Email/ID Penyetoer',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: AppColors.accent, width: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tambah Item Sampah',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TrashType>(
                    value: _selectedTrashType,
                    decoration: InputDecoration(
                      labelText: 'Jenis Sampah',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: AppColors.accent, width: 2.0),
                      ),
                    ),
                    items: TrashType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedTrashType = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _currentWeightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Berat (kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: AppColors.accent, width: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addTrashItem,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Tambah Item', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: AppColors.infoBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Item Sampah yang Ditambahkan:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 16),
                  _addedTrashItems.isEmpty
                      ? const Text('Belum ada item ditambahkan.', style: TextStyle(color: AppColors.secondary))
                      : Column(
                          children: _addedTrashItems.map((item) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              color: AppColors.background,
                              child: ListTile(
                                title: Text('${item.key.label}: ${item.value.toStringAsFixed(1)} kg'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.errorRed),
                                  onPressed: () => _removeTrashItem(item.key),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 20),
                  Text(
                    'Total Estimated Price for Penyetoer: Rp${_totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitTrashData,
                      icon: const Icon(Icons.upload_file, color: Colors.white),
                      label: const Text('Kirim Data Sampah', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Bukti Foto',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 16),
                  _imageFile == null
                      ? Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.camera_alt, size: 50, color: AppColors.secondary),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
                        ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library, color: Colors.white),
                      label: const Text('Pilih Gambar', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: AppColors.infoBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pelaporan Insiden',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _incidentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Insiden',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: AppColors.accent, width: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _reportIncident,
                      icon: const Icon(Icons.report_problem, color: Colors.white),
                      label: const Text('Laporkan Insiden', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: AppColors.errorRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
