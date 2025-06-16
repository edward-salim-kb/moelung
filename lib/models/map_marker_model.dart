 import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart'; // For IconData

enum MarkerType {
  tikoem,
  jempoet, // Trash to be picked up by Kolektoer
  kumpul, // Trash collected by Penyetoer
  kolektoer, // Kolektoer's current location
  penyetoer, // Penyetoer's current location
  info, // For informational markers like historical route labels
}

class MapMarker {
  final String id;
  final LatLng position;
  final MarkerType type;
  final String? label;
  final IconData? icon;
  final Color? color;

  MapMarker({
    required this.id,
    required this.position,
    required this.type,
    this.label,
    this.icon,
    this.color,
  });
}
