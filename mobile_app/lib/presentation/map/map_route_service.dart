import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;
import 'dart:convert';

class MapRouteService {
  static const String _sourceId = "route-source";
  static const String _layerId = "route-layer";


  Future<void> drawRoute(mbx.MapboxMap map, List<mbx.Position> coords) async {
    if (coords.isEmpty) return;

    final line = mbx.LineString(coordinates: coords);
    await _setGeoJsonSource(map, line);

    // Check the style directly instead of using a local boolean
    final exists = await map.style.getLayer(_layerId);
    if (exists == null) {
      await _addRouteLayer(map);
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
    await map.style.addLayer(
      mbx.LineLayer(
        id: _layerId,
        sourceId: _sourceId,
        // Use the lineProperty fields for settings
        lineColor: 14233648, // Pass the integer value
        lineWidth: 5.0,
        lineJoin: mbx.LineJoin.ROUND,
        lineCap: mbx.LineCap.ROUND,
      ),
    );
  }
}
