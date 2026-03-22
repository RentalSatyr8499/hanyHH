import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

class LocationService {
  /// For now: parse "lat, lng" into a Mapbox Position
  mbx.Position? parseLatLng(String input) {
    try {
      final parts = input.split(',');
      if (parts.length != 2) return null;

      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());

      return mbx.Position(lng, lat); // Mapbox uses (lng, lat)
    } catch (_) {
      return null;
    }
  }
}
