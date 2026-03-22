import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

class MapAnnotationService {
  mbx.PointAnnotationManager? _manager;
  mbx.PointAnnotation? _sourcePin;
  mbx.PointAnnotation? _destinationPin;

  Future<void> _ensureManager(mbx.MapboxMap map) async {
    _manager ??= await map.annotations.createPointAnnotationManager();
  }

  bool get hasSource => _sourcePin != null;
  mbx.Position get sourcePos => _sourcePin!.geometry.coordinates;

  Future<void> setSourcePin(mbx.MapboxMap map, mbx.Position pos) async {
    await _ensureManager(map);

    if (_sourcePin != null) {
      await _manager!.delete(_sourcePin!);
    }

    _sourcePin = await _manager!.create(
      mbx.PointAnnotationOptions(
        geometry: mbx.Point(coordinates: pos),
        iconImage: 'marker',
        iconSize: 1.2,
      ),
    );
  }

  Future<void> setDestinationPin(mbx.MapboxMap map, mbx.Position pos) async {
    await _ensureManager(map);

    if (_destinationPin != null) {
      await _manager!.delete(_destinationPin!);
    }

    _destinationPin = await _manager!.create(
      mbx.PointAnnotationOptions(
        geometry: mbx.Point(coordinates: pos),
        iconImage: 'marker',
        iconSize: 1.2,
      ),
    );
  }
}
