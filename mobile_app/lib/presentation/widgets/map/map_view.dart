import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

class MapView extends StatelessWidget {
  final void Function(mbx.MapboxMap) onMapCreated;

  const MapView({
    super.key,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return mbx.MapWidget(
      key: const ValueKey("main-map"),
      onMapCreated: onMapCreated,
    );
  }
}

