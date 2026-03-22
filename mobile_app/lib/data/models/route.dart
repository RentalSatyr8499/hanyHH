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
      distanceMeters: json['distance_meters'],
      durationSeconds: json['duration_seconds'],
      coordinates: List<List<double>>.from(
        json['geometry']['coordinates'].map(
          (c) => [c[0], c[1]],
        ),
      ),
    );
  }

  List<mbx.Position> toPositions() {
    return coordinates
        .map((c) => mbx.Position(c[0], c[1])) // [lng, lat]
        .toList();
  }
}
