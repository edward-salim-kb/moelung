import 'package:moelung_new/models/tikoem_model.dart';
import 'package:latlong2/latlong.dart';

Future<List<Tikoem>> fetchTikoems() async {
  // Dummy data for now
  return [
    Tikoem(name: 'Dummy Tikoem 1', location: LatLng(-6.36806, 106.82719)),
    Tikoem(name: 'Dummy Tikoem 2', location: LatLng(-6.37000, 106.83000)),
  ];
}
