import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

class RouteStep {
  final String instruction;
  final RouteGeometry geometry;

  RouteStep({
    required this.instruction,
    required this.geometry,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'] as String,
      geometry: RouteGeometry.fromJson(json['geometry'] as Map<String, dynamic>),
    );
  }
}

class RouteGeometry {
  final List<List<double>> coordinates;

  RouteGeometry({required this.coordinates});

  factory RouteGeometry.fromJson(Map<String, dynamic> json) {
    final coordsList = json['coordinates'] as List;
    return RouteGeometry(
      coordinates: coordsList.map<List<double>>((dynamic c) {
        return <double>[
          (c[0] as num).toDouble(),
          (c[1] as num).toDouble(),
        ];
      }).toList(),
    );
  }
}

class RouteModel {
  final double distanceMeters;
  final double durationSeconds;
  final List<List<double>> coordinates;
  final List<RouteStep> steps; // Added to fix the controller error

  RouteModel({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.coordinates,
    required this.steps,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>;
    final coordsList = geometry['coordinates'] as List;

    // Parsing steps using the same logic as your original coordinates
    final stepsList = json['steps'] as List;

    return RouteModel(
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      durationSeconds: (json['duration_seconds'] as num).toDouble(),
      coordinates: coordsList.map<List<double>>((dynamic c) {
        return <double>[
          (c[0] as num).toDouble(),
          (c[1] as num).toDouble(),
        ];
      }).toList(),
      steps: stepsList.map<RouteStep>((dynamic s) {
        return RouteStep.fromJson(s as Map<String, dynamic>);
      }).toList(),
    );
  }

  List<mbx.Position> toPositions() {
    return coordinates
        .map((c) => mbx.Position(c[0], c[1]))
        .toList();
  }
}