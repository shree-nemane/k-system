import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../core/logger_service.dart';

/// Service that fetches road-following routes from OSRM (Open Source Routing Machine).
/// Uses the free public demo server — no API key needed.
class RoutingService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1';

  /// Fetch a walking route between [origin] and [destination].
  /// Returns a list of [LatLng] points following actual roads.
  /// Falls back to a straight line if the API fails.
  static Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    // OSRM expects coordinates as lng,lat (not lat,lng)
    final url = Uri.parse(
      '$_baseUrl/foot/${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List?;

        if (routes != null && routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coordinates = geometry['coordinates'] as List;

          // OSRM returns [lng, lat], convert to LatLng
          final points = coordinates
              .map((coord) => LatLng(
                    (coord[1] as num).toDouble(),
                    (coord[0] as num).toDouble(),
                  ))
              .toList();

          Log.info('OSRM route fetched: ${points.length} points');
          return points;
        }
      }

      Log.warning('OSRM returned no routes (status: ${response.statusCode})');
    } catch (e) {
      Log.error('OSRM routing failed — falling back to straight line', e);
    }

    // Fallback: straight line (original behavior)
    return [origin, destination];
  }
}
