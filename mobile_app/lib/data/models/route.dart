import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

class RouteModel {
  final double distanceMeters;
  final double durationSeconds;
  final List<List<double>> coordinates;

  RouteModel({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.coordinates,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      durationSeconds: (json['duration_seconds'] as num).toDouble(),
      coordinates: (json['geometry']['coordinates'] as List)
          .map<List<double>>(
            (c) => [
              (c[0] as num).toDouble(),
              (c[1] as num).toDouble(),
            ],
          )
          .toList(),
    );
  }


  List<mbx.Position> toPositions() {
    return coordinates
        .map((c) => mbx.Position(c[0], c[1])) // [lng, lat]
        .toList();
  }
}
