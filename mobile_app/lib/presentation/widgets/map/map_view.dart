import 'package:flutter/material.dart';
import 'map_expanded_view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MapExpandedView()),
        );
      },
      child: const mbx.MapWidget(), // your existing mapbox widget
    );
  }
}
