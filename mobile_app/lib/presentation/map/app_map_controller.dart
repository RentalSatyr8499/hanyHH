import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;
import '../../data/services/location_service.dart';
import 'map_init_service.dart';
import 'map_camera_service.dart';
import 'map_annotation_service.dart';
import 'map_route_service.dart';


class AppMapController {
  final LocationService _locationService = LocationService();
  final MapInitService _init = MapInitService();
  final MapCameraService _camera = MapCameraService();
  final MapAnnotationService _annotations = MapAnnotationService();
  final MapRouteService _routes = MapRouteService();

  mbx.MapboxMap? _map;

  Future<void> init(mbx.MapboxMap controller) async {
    _map = controller;
    await _init.initialize(controller);
  }

  Future<void> setSource(String input) async {
    if (_map == null) return;

    final pos = _locationService.parseLatLng(input);
    if (pos == null) return;

    await _annotations.setSourcePin(_map!, pos);
    await _camera.flyToPosition(_map!, pos);
  }

  Future<void> setDestination(String input) async {
    if (_map == null) return;

    final pos = _locationService.parseLatLng(input);
    if (pos == null) return;

    await _annotations.setDestinationPin(_map!, pos);

    if (_annotations.hasSource) {
      await _camera.fitTwoPoints(_map!, _annotations.sourcePos, pos);
    }
  }

  Future<void> drawRoute(List<mbx.Position> coords) async {
    if (_map == null) return;
    await _routes.drawRoute(_map!, coords);
  }

}
