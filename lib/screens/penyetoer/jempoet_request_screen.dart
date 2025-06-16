import 'package:flutter/material.dart';
import 'package:moelung_new/widgets/common/page_header.dart';
import 'package:moelung_new/models/enums/trash_type.dart';
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/services/pickup_service.dart'; // Import PickupService
import 'package:moelung_new/config/app_routes.dart'; // Import AppRoutes
import 'package:moelung_new/models/index.dart'; // Import ServiceType
import 'package:latlong2/latlong.dart'; // Import LatLng for dummy location
import 'package:provider/provider.dart'; // Import Provider

class JempoetRequestScreen extends StatefulWidget {
  final UserModel currentUser;

  const JempoetRequestScreen({super.key, required this.currentUser});

  @override
  State<JempoetRequestScreen> createState() => _JempoetRequestScreenState();
}

class _JempoetRequestScreenState extends State<JempoetRequestScreen> {
  TrashType? _selectedTrashType;
  final TextEditingController _currentWeightController = TextEditingController();
  final List<MapEntry<TrashType, double>> _addedTrashItems = [];
  double _totalPrice = 0.0;
  bool _isSubmitting = false; // New state for loading indicator

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

  Future<void> _requestJempoet() async {
    if (_addedTrashItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon tambahkan setidaknya satu item sampah untuk mengajukan jempoet.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final pickupService = Provider.of<PickupService>(context, listen: false);

    // For now, use a dummy location for the pickup request
    final LatLng dummyLocation = LatLng(-6.2088, 106.8456); // Example: Jakarta

    try {
      await pickupService.createPickupRequest(
        penyetoerId: widget.currentUser.id,
        penyetoerName: widget.currentUser.name,
        location: dummyLocation,
        address: 'Jl. Contoh Alamat No. 123, Jakarta', // Dummy address
        totalWeight: _addedTrashItems.fold(0.0, (sum, item) => sum + item.value),
        trashBreakdown: Map.fromEntries(_addedTrashItems),
      );

      // Clear inputs after successful submission
      _currentWeightController.clear();
      setState(() {
        _addedTrashItems.clear();
        _totalPrice = 0.0;
        _isSubmitting = false;
      });

      // Navigate to the KumpoelJempoetScreen (map screen) in Jempoet mode
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.kumpoelJempoet,
        arguments: {
          'currentUser': widget.currentUser,
          'initialServiceType': ServiceType.jempoet,
        },
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengajukan jempoet: $e'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
    }
  }

  @override
  void dispose() {
    _currentWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const PageHeader(title: 'Ajukan Jempoet', showBackButton: false),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${widget.currentUser.name}!',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Silakan masukkan detail sampah yang ingin dijemput Kolektoer.',
                    style: TextStyle(fontSize: 16, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tambah Jenis Sampah',
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
                    'Total Estimasi Harga untuk Anda: Rp${_totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  _isSubmitting
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _requestJempoet,
                            icon: const Icon(Icons.send, color: Colors.white),
                            label: const Text('Ajukan Jempoet', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              textStyle: const TextStyle(fontSize: 18),
                              backgroundColor: AppColors.primary,
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
