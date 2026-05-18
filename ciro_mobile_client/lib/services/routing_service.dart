import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_config.dart';

class RoutingService {
  final Dio _dio;

  RoutingService(this._dio);

  /// Gets route waypoints between two points using OpenRouteService.
  /// Returns a list of LatLng points for drawing the polyline.
  Future<List<LatLng>> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConfig.orsBaseUrl}/v2/directions/driving-car',
        queryParameters: {
          'start': '$startLng,$startLat',
          'end': '$endLng,$endLat',
        },
        options: Options(
          headers: {
            'Authorization': AppConfig.orsApiKey,
            'Accept': 'application/geo+json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final features = response.data['features'] as List?;
        if (features != null && features.isNotEmpty) {
          final geometry = features[0]['geometry'];
          if (geometry != null) {
            final coordinates = geometry['coordinates'] as List?;
            if (coordinates != null) {
              return coordinates.map((coord) {
                final lng = (coord[0] as num).toDouble();
                final lat = (coord[1] as num).toDouble();
                return LatLng(lat, lng);
              }).toList();
            }
          }
        }
      }
      throw Exception('Invalid response structure or empty route from routing API');
    } catch (e) {
      throw Exception('Failed to fetch route: $e');
    }
  }
}
