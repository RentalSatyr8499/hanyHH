import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;
import 'dart:convert';
import 'dart:async'; // Required for Timer/Delay

class MapRouteService {
  static const String _sourceId = "route-source";
  static const String _layerId = "route-layer";

  Future<void> drawRoute(mbx.MapboxMap map, List<mbx.Position> coords) async {
    if (coords.isEmpty) return;

    // 1. Ensure the Layer and Source exist first (empty or first point)
    await _prepareRouteLayer(map);

    // 2. Start the animation loop
    await _animateLine(map, coords);
  }

  Future<void> _prepareRouteLayer(mbx.MapboxMap map) async {
    // Check if source exists, if not, create it with an empty feature
    try {
      final existing = await map.style.getSource(_sourceId);
      if (existing == null) {
        await map.style.addSource(mbx.GeoJsonSource(id: _sourceId, data: '{"type": "FeatureCollection", "features": []}'));
      }
    } catch (e) {
       await map.style.addSource(mbx.GeoJsonSource(id: _sourceId, data: '{"type": "FeatureCollection", "features": []}'));
    }

    // Check if layer exists, if not, create it
    try {
      final layer = await map.style.getLayer(_layerId);
      if (layer == null) await _addRouteLayer(map);
    } catch (e) {
      await _addRouteLayer(map);
    }
  }

  Future<void> _animateLine(mbx.MapboxMap map, List<mbx.Position> fullCoords) async {
    final List<mbx.Position> currentSegment = [];
    
    // Adjust steps for speed: i += 1 is smooth, i += 5 is faster
    for (int i = 0; i < fullCoords.length; i++) {
      currentSegment.add(fullCoords[i]);

      final line = mbx.LineString(coordinates: currentSegment);
      final feature = mbx.Feature(id: "route-feature-id", geometry: line);
      final String geojsonString = jsonEncode(feature.toJson());

      // Update the source data property 
      await map.style.setStyleSourceProperty(_sourceId, 'data', geojsonString);

      // Control the animation speed (e.g., 16ms for ~60fps feel)
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }

  Future<void> _addRouteLayer(mbx.MapboxMap map) async {
    final lineLayer = mbx.LineLayer(
      id: _layerId,
      sourceId: _sourceId,
      lineColor: 0xFFD93030,
      lineWidth: 5.0,
      lineJoin: mbx.LineJoin.ROUND,
      lineCap: mbx.LineCap.ROUND,
    );
    await map.style.addLayer(lineLayer);
  }
}