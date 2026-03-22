import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

class MapInitService {
  Future<void> initialize(mbx.MapboxMap map) async {
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final bytes = await rootBundle.load('assets/marker.png');
      final list = bytes.buffer.asUint8List();

      await map.style.addStyleImage(
        'marker',
        1.0,
        mbx.MbxImage(width: 64, height: 64, data: list),
        false,
        [],
        [],
        null,
      );

      map.setCamera(
        mbx.CameraOptions(
          center: mbx.Point(coordinates: mbx.Position(0, 0)),
          zoom: 1.3,
        ),
      );

      print("✅ Map initialized");
    } catch (e) {
      print("❌ Map initialization error: $e");
    }
  }
}
