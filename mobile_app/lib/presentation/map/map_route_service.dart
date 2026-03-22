import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;
import 'dart:convert';

class MapRouteService {
  static const String _sourceId = "route-source";
  static const String _layerId = "route-layer";

  Future<void> drawRoute(mbx.MapboxMap map, List<mbx.Position> coords) async {
    if (coords.isEmpty) return;

    final line = mbx.LineString(coordinates: coords);
    
    // 1. Handle Source (Safe update or create)
    await _updateOrCreateSource(map, line);

    // 2. Handle Layer (Safe check existence)
    bool layerExists = false;
    try {
      final layer = await map.style.getLayer(_layerId);
      layerExists = (layer != null);
    } catch (e) {
      layerExists = false; 
    }

    if (!layerExists) {
      await _addRouteLayer(map);
    }
  }

  Future<void> _updateOrCreateSource(mbx.MapboxMap map, mbx.LineString line) async {
    final feature = mbx.Feature(id: "route-feature-id", geometry: line);
    final String geojsonString = jsonEncode(feature.toJson());

    bool sourceExists = false;
    try {
      final existing = await map.style.getSource(_sourceId);
      sourceExists = (existing != null);
    } catch (e) {
      sourceExists = false;
    }

    if (sourceExists) {
      await map.style.setStyleSourceProperty(_sourceId, 'data', geojsonString);
    } else {
      await map.style.addSource(
        mbx.GeoJsonSource(id: _sourceId, data: geojsonString),
      );
    }
  }

  Future<void> _addRouteLayer(mbx.MapboxMap map) async {
    // Note: Depending on your plugin version, you might need 
    // to pass properties in the constructor or via setters.
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