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

class TikoemMap extends StatefulWidget {
  const TikoemMap({super.key});

  @override
  State<TikoemMap> createState() => _TikoemMapState();
}

class _TikoemMapState extends State<TikoemMap> {
  final MapController _controller = MapController();
  final LatLng _fallbackCenter = const LatLng(-6.36806, 106.82719);

  LatLng? _userLocation;
  List<LatLng>? _routePoints;
  double? _distanceKm;
  bool _loadingRoute = false;
  String? _activeTikoemName;

  List<Tikoem> _tikoems = [];

  @override
  void initState() {
    super.initState();
    _initLocation();
    _loadTikoems();
  }

  Future<void> _initLocation() async {
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
      _controller.move(_userLocation!, 15);
    } catch (_) {}
  }

  Future<void> _loadTikoems() async {
    final tikoems = await fetchTikoems();
    if (!mounted) return;
    setState(() => _tikoems = tikoems);
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
        const SnackBar(content: Text('Couldn’t find a walking route.')),
      );
    } finally {
      if (mounted) setState(() => _loadingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapCenter = _userLocation ?? _fallbackCenter;

    return Column( // Wrap with Column to add PageHeader
      children: [
        const PageHeader(title: 'Map'), // Add the PageHeader
        Expanded( // Wrap the map content in Expanded
          child: Stack(
            children: [
              FlutterMap(
                mapController: _controller,
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 15,
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
                    markers: [
                      ..._tikoems.map(
                        (tikoem) => Marker(
                          point: tikoem.location,
                          width: 48,
                          height: 48,
                          child: GestureDetector(
                            onTap: () => _onTikoemTap(tikoem),
                            child: const _RecyclePin(size: 48),
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

              if (_activeTikoemName != null)
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

class _RecyclePin extends StatelessWidget {
  const _RecyclePin({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final double iconSize = size * 0.55;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Icon(Icons.location_pin, size: size, color: AppColors.accent),
          Positioned(
            top: size * 0.18,
            child: Container(
              width: iconSize,
              height: iconSize,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.recycling,
                size: iconSize * 0.65,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
