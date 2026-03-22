import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

class MapView extends StatefulWidget {
  final void Function(mbx.MapboxMap) onMapCreated;

  const MapView({
    super.key,
    required this.onMapCreated,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  mbx.MapboxMap? mapboxMap;

  @override
  Widget build(BuildContext context) {
    return mbx.MapWidget(
      onMapCreated: (controller) {
        mapboxMap = controller;

        // Forward the controller up to HomeScreen
        widget.onMapCreated(controller);
      },
    );
  }
}
