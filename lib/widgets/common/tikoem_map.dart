import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/models/tikoem_model.dart';
import 'package:moelung_new/services/tikoem_service.dart';
import 'package:moelung_new/widgets/common/page_header.dart'; // Import PageHeader
import 'package:moelung_new/models/map_marker_model.dart'; // Import MapMarker and MarkerType

class TikoemMap extends StatefulWidget {
  final List<MapMarker>? markers; // New generic markers list
  final LatLng? initialCenter; // Optional initial center
  final double? initialZoom; // Optional initial zoom
  final List<Polyline>? polylines; // New: Optional list of polylines to draw

  const TikoemMap({
    super.key,
    this.markers,
    this.initialCenter,
    this.initialZoom,
    this.polylines, // Add to constructor
  });

  @override
  State<TikoemMap> createState() => _TikoemMapState();
}

class _TikoemMapState extends State<TikoemMap> {
  final MapController _controller = MapController();
  final LatLng _fallbackCenter = const LatLng(-6.36806, 106.82719); // Fallback if no user location

  LatLng? _userLocation; // Represents current user's location if not provided in markers
  List<LatLng>? _routePoints; // For displaying routes
  double? _distanceKm; // For displaying distance
  bool _loadingRoute = false;
  String? _activeTikoemName; // For displaying Tikoem name on tap

  List<Tikoem> _tikoems = []; // Only used if no specific markers are provided

  @override
  void initState() {
    super.initState();
    _initLocation(); // Always try to get user location
    if (widget.markers == null || widget.markers!.isEmpty) {
      _loadTikoems(); // Only load Tikoems if no specific markers are provided
    }
    // If markers are provided, fit bounds after user location is potentially fetched
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.markers != null && widget.markers!.isNotEmpty) {
        _fitBoundsToMarkers(widget.markers!);
      } else if (_userLocation != null) {
        _controller.move(_userLocation!, widget.initialZoom ?? 15);
      }
    });
  }

  void _fitBoundsToMarkers(List<MapMarker> markers) {
    if (markers.isEmpty) return;
    if (markers.length == 1) {
      _controller.move(markers.first.position, widget.initialZoom ?? 15);
    } else {
      final points = markers.map((m) => m.position).toList();
      _controller.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(60),
        ),
      );
    }
  }

  // This method is now only for fetching user's current location if not already set
  Future<void> _initLocation() async {
    if (_userLocation != null) return; // Already fetched

    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.deniedForever ||
            perm == LocationPermission.denied) {
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      if (!mounted) return;
      setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
      // If no specific markers are provided, move map to user location
      if (widget.markers == null || widget.markers!.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.move(_userLocation!, widget.initialZoom ?? 15);
        });
      }
    } catch (_) {
      // Handle location error, fallback to default center
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mendapatkan lokasi Anda. Menggunakan lokasi default.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
    }
  }

  // This method is now only for loading Tikoems if no markers are provided
  Future<void> _loadTikoems() async {
    // Pass the user's current location to fetchTikoems
    final tikoems = await fetchTikoems(userLocation: _userLocation);
    if (!mounted) return;
    setState(() => _tikoems = tikoems);
  }

  // This method is for calculating route between two specific points (e.g., Kolektoer and Pickup)
  Future<void> _calculateRoute(LatLng from, LatLng to) async {
    setState(() {
      _loadingRoute = true;
      _routePoints = null;
      _distanceKm = null;
    });

    try {
      final uri = _buildOsrmUri(from, to);
      final res = await http.get(uri);

      if (res.statusCode != 200) {
        throw Exception('OSRM error ${res.statusCode}');
      }

      final data = json.decode(res.body) as Map<String, dynamic>;
      final routes = (data['routes'] ?? []) as List<dynamic>;
      if (routes.isEmpty) throw Exception('No pedestrian route found');

      final shortest = routes.first as Map<String, dynamic>;
      final coords = (shortest['geometry']['coordinates'] as List<dynamic>);
      final points =
          coords
              .map<LatLng>((c) => LatLng(c[1] as double, c[0] as double))
              .toList();
      final distanceKm = (shortest['distance'] as num) / 1000.0;

      if (!mounted) return;
      setState(() {
        _routePoints = points;
        _distanceKm = distanceKm;
      });

      _controller.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(60),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn’t find a walking route.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingRoute = false);
    }
  }

  Uri _buildOsrmUri(LatLng from, LatLng to) {
    return Uri(
      scheme: 'https',
      host: 'router.project-osrm.org',
      path:
          'route/v1/foot/${from.longitude},${from.latitude};${to.longitude},${to.latitude}',
      queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'false',
      },
    );
  }

  // This method is for Tikoem tap, will be adapted or removed if not needed with generic markers
  Future<void> _onTikoemTap(Tikoem tikoem) async {
    if (_userLocation == null || _loadingRoute) return;

    setState(() {
      _loadingRoute = true;
      _routePoints = null;
      _distanceKm = null;
      _activeTikoemName = tikoem.name;
    });

    try {
      final uri = _buildOsrmUri(_userLocation!, tikoem.location);
      final res = await http.get(uri);

      if (res.statusCode != 200) {
        throw Exception('OSRM error ${res.statusCode}');
      }

      final data = json.decode(res.body) as Map<String, dynamic>;
      final routes = (data['routes'] ?? []) as List<dynamic>;
      if (routes.isEmpty) throw Exception('No pedestrian route found');

      final shortest = routes.first as Map<String, dynamic>;
      final coords = (shortest['geometry']['coordinates'] as List<dynamic>);
      final points =
          coords
              .map<LatLng>((c) => LatLng(c[1] as double, c[0] as double))
              .toList();
      final distanceKm = (shortest['distance'] as num) / 1000.0;

      if (!mounted) return;
      setState(() {
        _routePoints = points;
        _distanceKm = distanceKm;
      });

      _controller.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(60),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn’t find a walking route.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = widget.initialCenter ?? _userLocation ?? _fallbackCenter;

    return Column(
      children: [
        // Only show PageHeader if no specific markers are provided (i.e., general map view)
        if (widget.markers == null || widget.markers!.isEmpty) const PageHeader(title: 'Map'),
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _controller,
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: widget.initialZoom ?? 15,
                  maxZoom: 18,
                  onPositionChanged: (_, __) {
                    if (_activeTikoemName != null && mounted) {
                      setState(() => _activeTikoemName = null);
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    userAgentPackageName: 'com.example.app',
                  ),
                  // Draw polylines passed from outside
                  if (widget.polylines != null && widget.polylines!.isNotEmpty)
                    PolylineLayer(polylines: widget.polylines!),
                  // Draw internal route points if any
                  if (_routePoints != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints!,
                          strokeWidth: 4,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: widget.markers != null && widget.markers!.isNotEmpty
                        ? widget.markers!.map((marker) {
                            IconData iconData;
                            Color iconColor;
                            double iconSize = 32;

                            switch (marker.type) {
                              case MarkerType.tikoem:
                                iconData = Icons.recycling;
                                iconColor = AppColors.accent;
                                iconSize = 48;
                                break;
                              case MarkerType.jempoet:
                                iconData = Icons.delivery_dining;
                                iconColor = AppColors.primary;
                                iconSize = 40;
                                break;
                              case MarkerType.kumpul:
                                iconData = Icons.shopping_bag;
                                iconColor = AppColors.secondary;
                                iconSize = 40;
                                break;
                              case MarkerType.kolektoer:
                                iconData = Icons.motorcycle; // Changed back to motorcycle icon
                                iconColor = AppColors.infoBlue;
                                iconSize = 32;
                                break;
                              case MarkerType.penyetoer:
                                iconData = CupertinoIcons.person_solid;
                                iconColor = AppColors.dark;
                                iconSize = 32;
                                break;
                              case MarkerType.info: // Handle info marker type
                                return Marker(
                                  point: marker.position,
                                  width: 150, // Adjust width for text label
                                  height: 30, // Adjust height for text label
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      marker.label ?? '',
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                            }

                            return Marker(
                              point: marker.position,
                              width: iconSize,
                              height: iconSize,
                              child: Icon(
                                iconData,
                                color: iconColor,
                                size: iconSize,
                              ),
                            );
                          }).toList()
                        : [
                            // Existing markers for Tikoems (if no specific markers provided)
                            ..._tikoems.map(
                              (tikoem) => Marker(
                                point: tikoem.location,
                                width: 48,
                                height: 48,
                                child: GestureDetector(
                                  onTap: () => _onTikoemTap(tikoem),
                                  child: Icon(
                                    Icons.recycling, // Confirmed recycling icon
                                    size: 48,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ),
                            if (_userLocation != null)
                              Marker(
                                point: _userLocation!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  CupertinoIcons.location_solid,
                                  color: AppColors.accent,
                                  size: 32,
                                ),
                              ),
                          ],
                  ),
                ],
              ),

              if (_distanceKm != null)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_distanceKm!.toStringAsFixed(2)} km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              if (_activeTikoemName != null && (widget.markers == null || widget.markers!.isEmpty)) // Only show Tikoem name if not in generic marker mode
                Positioned(
                  top: 60,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _activeTikoemName!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              if (_loadingRoute)
                const Positioned(
                  top: 16,
                  right: 16,
                  child: CupertinoActivityIndicator(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
