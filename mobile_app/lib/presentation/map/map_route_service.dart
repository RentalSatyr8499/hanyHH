import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;
import 'dart:convert';

class MapRouteService {
  static const String _sourceId = "route-source";
  static const String _layerId = "route-layer";

  bool _layerAdded = false;

  Future<void> drawRoute(mbx.MapboxMap map, List<mbx.Position> coords) async {
    if (coords.isEmpty) return;

    // 1. Build a LineString geometry
    final line = mbx.LineString(coordinates: coords);

    // 2. Create/update the GeoJSON source
    await _setGeoJsonSource(map, line);

    // 3. Add the line layer if needed
    if (!_layerAdded) {
      await _addRouteLayer(map);
      _layerAdded = true;
    }
  }

  Future<void> _setGeoJsonSource(mbx.MapboxMap map, mbx.LineString line) async {
    // 2. Add an 'id' to the Feature constructor
    final feature = mbx.Feature(
      id: "route-feature-id", 
      geometry: line,
    );

    final String geojsonString = jsonEncode(feature.toJson());

    final existing = await map.style.getSource(_sourceId);

    if (existing != null) {
      // Update existing
      await map.style.setStyleSourceProperty(_sourceId, 'data', geojsonString);
    } else {
      // 3. Ensure GeoJsonSource also has its required 'id'
      await map.style.addSource(
        mbx.GeoJsonSource(
          id: _sourceId, 
          data: geojsonString,
        ),
      );
    }
  }

  Future<void> _addRouteLayer(mbx.MapboxMap map) async {
    await map.style.addLayer(
      mbx.LineLayer(
        id: _layerId,
        sourceId: _sourceId,
        lineColor: 0xFF0066FF, // blue
        lineWidth: 5.0,
        lineJoin: mbx.LineJoin.ROUND,
        lineCap: mbx.LineCap.ROUND,
      ),
    );
  }
}
