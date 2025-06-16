import 'package:flutter/material.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart';
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/models/pickup_request_model.dart';
import 'package:moelung_new/services/pickup_service.dart';
import 'package:latlong2/latlong.dart'; // For LatLng and Distance
import 'package:moelung_new/widgets/common/tikoem_map.dart'; // For TikoemMap
import 'package:moelung_new/models/enums/trash_type.dart'; // For TrashType extension
import 'package:moelung_new/models/enums/pickup_status.dart'; // Import PickupStatus
import 'package:moelung_new/models/map_marker_model.dart'; // Import MapMarker and MarkerType
import 'package:geolocator/geolocator.dart'; // Import Geolocator
// Removed: import 'dart:convert';
// Removed: import 'package:http/http.dart' as http;
// Removed: import 'dart:math';
import 'package:flutter_map/flutter_map.dart'; // Import for Polyline (still needed for straight line)

class KolektoerPickupServiceScreen extends StatefulWidget {
  final UserModel currentUser;

  const KolektoerPickupServiceScreen({super.key, required this.currentUser});

  @override
  State<KolektoerPickupServiceScreen> createState() =>
      _KolektoerPickupServiceScreenState();
}

class _KolektoerPickupServiceScreenState
    extends State<KolektoerPickupServiceScreen> {
  List<PickupRequest> _pickupRequests = [];
  bool _isLoading = true;
  LatLng? _kolektoerLocation; // Actual Kolektoer location

  @override
  void initState() {
    super.initState();
    _initKolektoerLocationAndFetchRequests();
  }

  Future<void> _initKolektoerLocationAndFetchRequests() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
          // Handle permission denied, use fallback
          _kolektoerLocation = LatLng(-6.2088, 106.8456); // Fallback dummy location
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gagal mendapatkan lokasi Anda. Menggunakan lokasi default.'),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
              ),
            );
          }
        }
      }
      if (_kolektoerLocation == null) { // Only get current position if not already set by fallback
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        _kolektoerLocation = LatLng(pos.latitude, pos.longitude);
      }
    } catch (e) {
      _kolektoerLocation = LatLng(-6.2088, 106.8456); // Fallback dummy location
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mendapatkan lokasi Anda. Menggunakan lokasi default.'),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
          ),
        );
      }
    } finally {
      // After getting location, fetch pickup requests
      _fetchPickupRequests();
    }
  }

  Future<void> _fetchPickupRequests() async {
    if (_kolektoerLocation == null) {
      // Wait for location to be initialized if not already
      await _initKolektoerLocationAndFetchRequests();
      if (_kolektoerLocation == null) { // If still null, something went wrong
        setState(() => _isLoading = false);
        return;
      }
    }
    try {
      final requests = await PickupService.fetchAllPickupRequestsForKolektoer(userLocation: _kolektoerLocation!);
      setState(() {
        _pickupRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat permintaan jemput: $e'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
    }
  }

  String _formatDistance(LatLng requestLocation) {
    if (_kolektoerLocation == null) return 'N/A';
    final Distance distance = const Distance();
    final double meters = distance(_kolektoerLocation!, requestLocation);
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 0, // Set to 0 for Home
      user: widget.currentUser,
      body: Column(
        children: [
          const PageHeader(title: 'Layanan Jemput', showBackButton: false),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _pickupRequests.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada permintaan jemput tersedia.',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang, Kolektoer ${widget.currentUser.name}!',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Permintaan Jemput Tertunda:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _pickupRequests.length,
                          itemBuilder: (context, index) {
                            final request = _pickupRequests[index];
                            return _buildPickupRequestCard(context, request);
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupRequestCard(BuildContext context, PickupRequest request) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () => _showPickupRequestDetailsDialog(context, request),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: AssetImage('lib/assets/avatars/image.png'), // Placeholder avatar
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Permintaan dari: ${request.penyetoerName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Alamat: ${request.address}',
                style: const TextStyle(
                  color: AppColors.dark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Jarak: ${_formatDistance(request.location)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.infoBlue,
                ),
              ),
              const SizedBox(height: 16), // Re-add spacing before buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribute buttons
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement accept logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Menerima jemputan dari ${request.penyetoerName}'),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, color: Colors.white, size: 18), // Smaller icon
                    label: const Text('Terima', style: TextStyle(color: Colors.white, fontSize: 14)), // Smaller text
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Smaller padding
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement decline logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Menolak jemputan dari ${request.penyetoerName}'),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
                        ),
                      );
                    },
                    icon: const Icon(Icons.close, color: Colors.white, size: 18), // Smaller icon
                    label: const Text('Tolak', style: TextStyle(color: Colors.white, fontSize: 14)), // Smaller text
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Smaller padding
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPickupRequestDetailsDialog(BuildContext context, PickupRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.dark, // Dark background for the dialog
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            'Detail Permintaan Jemput dari ${request.penyetoerName}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0), // Adjust padding
          content: SizedBox( // Explicitly size the content area
            width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
            height: MediaQuery.of(context).size.height * 0.6, // 60% of screen height
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Alamat: ${request.address}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('Total Berat: ${request.totalWeight.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('Diminta Pada: ${request.requestedAt.toLocal().toString().split('.')[0]}', style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${request.status.label}',
                    style: TextStyle(
                      color: request.status == PickupStatus.requested ? AppColors.secondary : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Rincian Sampah:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...request.trashBreakdown.entries.map(
                    (entry) => Text(
                      '  - ${entry.key.label}: ${entry.value.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        color: AppColors.infoBlue, // Different color for details
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    width: double.maxFinite, // Take available width within the sized box
                    child: TikoemMap(
                      markers: [
                        MapMarker(
                          id: request.id,
                          position: request.location,
                          type: MarkerType.jempoet,
                          label: request.penyetoerName,
                        ),
                        if (_kolektoerLocation != null)
                          MapMarker(
                            id: 'kolektoer_current_location',
                            position: _kolektoerLocation!,
                            type: MarkerType.kolektoer,
                            label: 'Lokasi Kamu',
                          ),
                      ],
                      polylines: _kolektoerLocation != null
                          ? [
                              Polyline(
                                points: [_kolektoerLocation!, request.location],
                                color: AppColors.primary,
                                strokeWidth: 4.0,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                // TODO: Implement accept logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Menerima jemputan dari ${request.penyetoerName}'),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
                  ),
                );
              },
              child: const Text('Terima', style: TextStyle(color: AppColors.primary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
                // TODO: Implement decline logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Menolak jemputan dari ${request.penyetoerName}'),
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
                  ),
                );
              },
              child: const Text('Tolak', style: TextStyle(color: AppColors.secondary)),
            ),
          ],
        );
      },
    );
  }
}
