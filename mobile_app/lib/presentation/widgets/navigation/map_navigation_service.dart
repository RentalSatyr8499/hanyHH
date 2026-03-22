import 'dart:math' as math;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapNavigationService {
  final MapboxMap map;

  MapNavigationService(this.map);

  Future<void> moveToStep(List<List<double>> coords) async {
    if (coords.isEmpty) return;

    final current = coords.first;
    double? bearing;

    // Calculate bearing if there is a second point to look toward
    if (coords.length > 1) {
      final next = coords[1];
      bearing = _calculateBearing(
        current[1], current[0], // lat1, lng1
        next[1], next[0],       // lat2, lng2
      );
    }
    
    final offsetPos = _getOffsetPoint(current[0], current[1], bearing ?? 0, 10); // 10 meters forward

    await map.flyTo(
      CameraOptions(
        center: Point(coordinates: offsetPos),
        zoom: 20.0,
        bearing: bearing,
        pitch: 70.0,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    double lat1Rad = lat1 * math.pi / 180;
    double lat2Rad = lat2 * math.pi / 180;
    double dLon = (lon2 - lon1) * math.pi / 180;

    double y = math.sin(dLon) * math.cos(lat2Rad);
    double x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);
    
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }
  
  Future<void> enterNavigationTilt() async {
    await map.setCamera(
      CameraOptions(
        pitch: 60.0,
        zoom: 40.0,
      ),
    );
  }

  Future<void> resetTilt() async {
    await map.setCamera(
      CameraOptions(
        pitch: 0.0,
        zoom: 14.0,
      ),
    );
  }

  Position _getOffsetPoint(double lon, double lat, double bearing, double distanceInMeters) {
  const double earthRadius = 6378137.0;
  double d = distanceInMeters / earthRadius;
  double brng = bearing * math.pi / 180;
  double lat1 = lat * math.pi / 180;
  double lon1 = lon * math.pi / 180;

  double lat2 = math.asin(math.sin(lat1) * math.cos(d) +
      math.cos(lat1) * math.sin(d) * math.cos(brng));
  double lon2 = lon1 +
      math.atan2(math.sin(brng) * math.sin(d) * math.cos(lat1),
          math.cos(d) - math.sin(lat1) * math.sin(lat2));

  return Position(lon2 * 180 / math.pi, lat2 * 180 / math.pi);
}
}
