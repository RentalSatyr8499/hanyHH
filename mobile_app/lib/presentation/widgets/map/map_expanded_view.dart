import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

class MapExpandedView extends StatelessWidget {
  const MapExpandedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const mbx.MapWidget(),
          Positioned(
            top: 40,
            left: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
