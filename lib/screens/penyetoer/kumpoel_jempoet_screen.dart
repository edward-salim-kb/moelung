import 'package:flutter/material.dart';
import 'package:moelung_new/models/index.dart';
import 'package:moelung_new/models/map_marker_model.dart'; // Import MapMarker and MarkerType
import 'package:moelung_new/models/pickup_request_model.dart'; // Import PickupRequest
import 'package:moelung_new/models/tikoem_model.dart'; // Import Tikoem
import 'package:moelung_new/services/pickup_service.dart'; // Import PickupService
import 'package:moelung_new/services/tikoem_service.dart'; // Import TikoemService
import 'package:latlong2/latlong.dart'; // Import LatLng
import 'package:provider/provider.dart'; // Import Provider
import 'package:flutter_map/flutter_map.dart'; // Import flutter_map for Polyline and LatLngBounds
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import 'dart:async'; // Import for Timer
import 'dart:math'; // Import for Random
import 'package:moelung_new/models/enums/trash_type.dart'; // Explicitly import TrashType and its extension
import '../../widgets/common/page_header.dart';
import '../../widgets/common/app_shell.dart';
import '../../widgets/common/tikoem_map.dart';
import '../../widgets/penyetoer/jempoet_drawer.dart';
import '../../widgets/penyetoer/kumpoel_drawer.dart';

// New class for EquipmentItem
class EquipmentItem {
  final String name;
  final IconData icon;

  EquipmentItem({required this.name, required this.icon});
}

class KumpoelJempoetScreen extends StatefulWidget {
  const KumpoelJempoetScreen({
    super.key,
    required this.currentUser,
    this.initialServiceType, // New parameter
  });

  final UserModel currentUser;
  final ServiceType? initialServiceType; // New parameter

  @override
  State<KumpoelJempoetScreen> createState() => _KumpoelJempoetScreenState();
}

class _KumpoelJempoetScreenState extends State<KumpoelJempoetScreen> {
  ServiceType? _selectedType;
  List<PickupRequest> _jempoetRequests = [];
  List<Tikoem> _tikoems = []; // Using Tikoem locations as "kumpul" points for now
  LatLng? _penyetoerLocation; // User's current location
  Tikoem? _targetTikoem; // The tikoem the user is moving towards
  double _totalCollectedTrashWeight = 0.0; // Total trash collected by the user
  List<LatLng> _userRoutePoints = []; // Simulated route of the user
  List<HistoricalRoute> _otherPeopleRoutes = []; // Other people's historical routes
  final List<EquipmentItem> _equipmentList = [
    EquipmentItem(name: 'Masker', icon: Icons.masks),
    EquipmentItem(name: 'Sarung Tangan', icon: Icons.handshake),
    EquipmentItem(name: 'Karung Sampah', icon: Icons.recycling),
    EquipmentItem(name: 'Topi Moelung', icon: Icons.sports_baseball),
    EquipmentItem(name: 'Seragam Moelung', icon: Icons.checkroom),
    EquipmentItem(name: 'Sepatu Bot', icon: Icons.hiking),
    EquipmentItem(name: 'Asuransi Kesehatan', icon: Icons.health_and_safety),
  ]; // Dummy equipment list with icons
  final bool _isMotorcycleBorrowed = false; // Dummy motorcycle borrowing status
  DateTime? _kumpoelStartTime; // New: To track when Kumpoel started
  String _elapsedTime = '00:00:00'; // New: Formatted elapsed time
  Timer? _kumpoelTimer; // New: Timer for Kumpoel duration
  Timer? _userLocationSimulationTimer; // Timer for user location updates
  final Distance _distance = const Distance(); // For distance calculation

  @override
  void initState() {
    super.initState();
    _initPenyetoerLocationAndFetchData();
    _selectedType = widget.initialServiceType; // Set initial type from argument
    if (_selectedType == null) {
      Future.delayed(Duration.zero, _showModeSelection);
    }
  }

  @override
  void dispose() {
    _userLocationSimulationTimer?.cancel();
    _kumpoelTimer?.cancel(); // Cancel Kumpoel timer
    super.dispose();
  }

  Future<void> _initPenyetoerLocationAndFetchData() async {
    bool locationObtained = false;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        // Permissions denied, use fallback location and show a persistent dialog
        _penyetoerLocation = LatLng(-6.2000, 106.8100); // Fallback dummy location
        if (mounted) {
          _showLocationErrorDialog('Akses lokasi ditolak. Menggunakan lokasi default. Harap izinkan akses lokasi di pengaturan aplikasi Anda.');
        }
      } else {
        // Permissions granted, try to get current position
        final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
        setState(() {
          _penyetoerLocation = LatLng(pos.latitude, pos.longitude);
        });
        locationObtained = true;
      }
    } catch (e) {
      // Error getting location, use fallback and show a persistent dialog
      _penyetoerLocation = LatLng(-6.2000, 106.8100); // Fallback dummy location
      if (mounted) {
        _showLocationErrorDialog('Gagal mendapatkan lokasi Anda: ${e.toString()}. Menggunakan lokasi default.');
      }
    } finally {
      // After attempting to get location (either success or fallback), fetch data
      _fetchData();
    }
  }

  void _showLocationErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Peringatan Lokasi'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchData() async {
    if (_penyetoerLocation == null) {
      // If location is still null, something went wrong during initialization
      return;
    }
    try {
      final requests = await PickupService.fetchAllPickupRequestsForKolektoer(userLocation: _penyetoerLocation!); // Pass user location
      final tikoems = await fetchTikoems(userLocation: _penyetoerLocation!); // Pass user location
      final otherRoutes = await fetchDummyHistoricalRoutes(userLocation: _penyetoerLocation!); // Fetch historical routes

      setState(() {
        _jempoetRequests = requests;
        _tikoems = tikoems;
        _otherPeopleRoutes = otherRoutes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
    } finally {
      // if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper to generate a slightly winding path for simulation
  List<LatLng> _generateWindingPath(LatLng start, LatLng end, int segments, double windingFactor) {
    List<LatLng> path = [start];
    for (int i = 1; i <= segments; i++) {
      double t = i / segments;
      double lat = start.latitude + (end.latitude - start.latitude) * t;
      double lng = start.longitude + (end.longitude - start.longitude) * t;

      // Add a random offset to simulate winding
      double offsetLat = (Random().nextDouble() - 0.5) * windingFactor;
      double offsetLng = (Random().nextDouble() - 0.5) * windingFactor;

      path.add(LatLng(lat + offsetLat, lng + offsetLng));
    }
    return path;
  }

  void _startKumpoelSimulation() {
    if (_penyetoerLocation == null || _tikoems.isEmpty) return;

    // Choose a random tikoem as the target
    _targetTikoem = _tikoems[Random().nextInt(_tikoems.length)];
    _userRoutePoints = [_penyetoerLocation!]; // Start route from current location
    _totalCollectedTrashWeight = 0.0; // Reset collected trash

    final start = _penyetoerLocation!;
    final end = _targetTikoem!.location;
    
    // Generate a winding path instead of a straight line
    final simulatedPath = _generateWindingPath(start, end, 50, 0.001); // 50 segments, increased winding factor

    int currentStep = 0;
    int totalSteps = simulatedPath.length;

    _userLocationSimulationTimer?.cancel(); // Cancel any existing timer
    _userLocationSimulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) { // Faster updates
      if (currentStep >= totalSteps) {
        timer.cancel();
        // User arrived at tikoem, show trash collection dialog
        setState(() {
          _penyetoerLocation = end; // Ensure user is exactly at tikoem location
        });
        // Dialog is no longer shown automatically here.
        _targetTikoem = null; // Clear target after reaching it
        return;
      }

      setState(() {
        _penyetoerLocation = simulatedPath[currentStep];
        _userRoutePoints.add(simulatedPath[currentStep]);
      });
      currentStep++;
    });
  }

  void _showModeSelection() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pilih mode kamu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _optionTile(
                  ServiceType.kumpoel,
                  'Kumpoel',
                  Icons.local_shipping,
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() => _selectedType = ServiceType.kumpoel);
                    _startKumpoelSimulation(); // Start simulation when Kumpoel is selected
                    _startKumpoelTimer(); // Start Kumpoel timer
                  },
                ),
                const SizedBox(height: 12),
                _optionTile(ServiceType.jempoet, 'Jempoet', Icons.cyclone),
              ],
            ),
          ),
    );
  }

  void _startKumpoelTimer() {
    _kumpoelStartTime = DateTime.now();
    _kumpoelTimer?.cancel(); // Cancel any existing timer
    _kumpoelTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) { // Faster update for prototype
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        final duration = DateTime.now().difference(_kumpoelStartTime!);
        _elapsedTime = _formatDuration(duration);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Widget _optionTile(ServiceType type, String label, IconData icon, {VoidCallback? onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap ?? () {
        Navigator.of(context).pop();
        setState(() => _selectedType = type);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pickupService = Provider.of<PickupService>(context); // Get PickupService instance
    final activeJempoetRequest = pickupService.currentPickupRequest; // Get active request

    return AppShell(
      navIndex: 2,
      user: widget.currentUser,
      body: Column(
        children: [
          const PageHeader(title: 'Peta Kumpoel / Jempoet'),
          Expanded(
            child: Stack(
              children: [
                _buildMap(activeJempoetRequest), // Pass active request to map builder
                if (_selectedType != null)
                  if (_selectedType == ServiceType.kumpoel)
                    KumpoelDrawer(
                      totalCollectedTrashWeight: _totalCollectedTrashWeight,
                      userRoutePoints: _userRoutePoints,
                      onStartKumpoel: _startKumpoelSimulation,
                      equipmentList: _equipmentList,
                      isMotorcycleBorrowed: _isMotorcycleBorrowed,
                      onLogTrash: _onLogTrashPressed, // Pass the new callback
                      elapsedTime: _elapsedTime, // Pass elapsed time
                    )
                  else
                    JempoetDrawer(currentUser: widget.currentUser),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onLogTrashPressed() {
    _showCollectTrashDialog();
  }

  Widget _buildMap(PickupRequest? activeJempoetRequest) {
    List<MapMarker> markers = [];
    List<Polyline> polylines = []; // For drawing lines
    LatLng? mapCenter;
    double? mapZoom;

    if (_penyetoerLocation != null) {
      markers.add(MapMarker(
        id: 'penyetoer_location',
        position: _penyetoerLocation!,
        type: MarkerType.penyetoer,
        label: 'Lokasi Kamu',
      ));
      mapCenter = _penyetoerLocation;
      mapZoom = 13;
    }

    // Add user's simulated route
    if (_userRoutePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          points: _userRoutePoints,
          color: Colors.green, // Color for user's route
          strokeWidth: 4.0,
        ),
      );
    }

    // Add other people's historical routes
    for (var historicalRoute in _otherPeopleRoutes) {
      if (historicalRoute.points.isNotEmpty) {
        polylines.add(
          Polyline(
            points: historicalRoute.points,
            color: Colors.grey, // Color for historical routes
            strokeWidth: 2.0,
          ),
        );
        // Add a marker/label for the route's age
        markers.add(
          MapMarker(
            id: 'historical_route_${historicalRoute.walkedAt.millisecondsSinceEpoch}',
            position: historicalRoute.points.first, // Label at the start of the route
            type: MarkerType.info, // Use an info marker type
            label: 'Jalur dilewati ${DateTime.now().difference(historicalRoute.walkedAt).inDays} hari lalu',
          ),
        );
      }
    }

    if (_selectedType == ServiceType.jempoet) {
      if (activeJempoetRequest != null) {
        // Add active jempoet request markers
        if (activeJempoetRequest.collectorStartLocation != null) {
          markers.add(MapMarker(
            id: 'collector_start_location',
            position: activeJempoetRequest.collectorStartLocation!,
            type: MarkerType.tikoem, // Tikoem pin for collector start
            label: 'Tikoem Kolektoer',
          ));
        }
        if (activeJempoetRequest.currentCollectorLocation != null) {
          markers.add(MapMarker(
            id: 'current_collector_location',
            position: activeJempoetRequest.currentCollectorLocation!,
            type: MarkerType.kolektoer, // Kolektoer's current location
            label: activeJempoetRequest.collectorName ?? 'Kolektoer',
          ));
          // Draw line from collector to user
          if (_penyetoerLocation != null) {
            polylines.add(
              Polyline(
                points: [activeJempoetRequest.currentCollectorLocation!, _penyetoerLocation!],
                color: Colors.blue,
                strokeWidth: 4.0,
              ),
            );
          }
        }
        // Center map on collector and user if active request
        if (activeJempoetRequest.currentCollectorLocation != null && _penyetoerLocation != null) {
          final bounds = LatLngBounds.fromPoints([activeJempoetRequest.currentCollectorLocation!, _penyetoerLocation!]);
          mapCenter = bounds.center;
          mapZoom = 13; // Adjust zoom as needed
        }
      } else {
        // If no active request, show all pending jempoet requests (for Kolektoer view)
        for (var req in _jempoetRequests) {
          markers.add(MapMarker(
            id: req.id,
            position: req.location,
            type: MarkerType.jempoet,
            label: req.penyetoerName,
          ));
        }
      }
    } else if (_selectedType == ServiceType.kumpoel) {
      // Add tikoem locations as kumpul points
      for (var tikoem in _tikoems) {
        markers.add(MapMarker(
          id: tikoem.name,
          position: tikoem.location,
          type: MarkerType.tikoem, // Using tikoem type for kumpul points
          label: tikoem.name,
        ));
      }
    }

    return TikoemMap(
      markers: markers.isNotEmpty ? markers : null,
      polylines: polylines.isNotEmpty ? polylines : null, // Pass polylines
      initialCenter: mapCenter,
      initialZoom: mapZoom,
    );
  }

  Future<void> _showCollectTrashDialog() async {
    Map<TrashType, TextEditingController> controllers = {};
    Map<TrashType, double> currentLoggedWeights = {};
    double currentTotalEstimatedPrice = 0.0;

    // Initialize controllers for all trash types with 0.0
    for (var type in TrashType.values) {
      controllers[type] = TextEditingController(text: '0.0');
      currentLoggedWeights[type] = 0.0;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder to update dialog content dynamically
          builder: (context, setState) {
            void updatePrice() {
              double newTotal = 0.0;
              Map<TrashType, double> tempWeights = {};
              controllers.forEach((type, controller) {
                double weight = double.tryParse(controller.text) ?? 0.0;
                tempWeights[type] = weight;
                newTotal += (trashPrices[type] ?? 0.0) * weight;
              });
              setState(() {
                currentLoggedWeights = tempWeights;
                currentTotalEstimatedPrice = newTotal;
              });
            }

            return AlertDialog(
              title: const Text('Log Sampah (Estimasi Harga)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Total Perkiraan Harga: Rp ${currentTotalEstimatedPrice.toStringAsFixed(0)}'),
                    const SizedBox(height: 16),
                    const Text('Masukkan Berat Sampah per Jenis (kg):', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...TrashType.values.map((type) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: TextField(
                          controller: controllers[type],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: '${type.label} (kg)',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) => updatePrice(), // Update price on change
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Selesai'),
                  onPressed: () {
                    double totalLoggedWeight = 0.0;
                    controllers.forEach((type, controller) {
                      totalLoggedWeight += double.tryParse(controller.text) ?? 0.0;
                    });

                    Navigator.of(context).pop(); // Dismiss dialog first
                    if (mounted) { // Check if widget is still mounted after dialog is popped
                      this.setState(() { // Use outer setState for screen update
                        _totalCollectedTrashWeight += totalLoggedWeight;
                        // No specific tikoem to update here, as it's a general log
                      });
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Dispose controllers after dialog is closed
      controllers.forEach((type, controller) => controller.dispose());
    });
  }
}
