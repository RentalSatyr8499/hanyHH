import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;
import '../../data/services/location_service.dart';

class AppMapController {
  final LocationService _locationService = LocationService();

  mbx.MapboxMap? _map;
  mbx.PointAnnotationManager? _annotationManager;
  mbx.PointAnnotation? _sourcePin;
  mbx.PointAnnotation? _destinationPin;

  Future<void> init(mbx.MapboxMap controller) async {
    _map = controller;

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      _annotationManager = await controller.annotations.createPointAnnotationManager();

      final bytes = await rootBundle.load('assets/marker.png');
      final list = bytes.buffer.asUint8List();

      await controller.style.addStyleImage(
        'marker',
        1.0,
        mbx.MbxImage(width: 64, height: 64, data: list),
        false,
        [],
        [],
        null,
      );

      controller.setCamera(
        mbx.CameraOptions(
          center: mbx.Point(coordinates: mbx.Position(0, 0)),
          zoom: 1.3,
        ),
      );
    } catch (e) {
      print("❌ Map Initialization Error: $e");
    }
  }

  mbx.CoordinateBounds _boundsForTwoPoints(mbx.Position a, mbx.Position b) {
    final minLng = a.lng < b.lng ? a.lng : b.lng;
    final maxLng = a.lng > b.lng ? a.lng : b.lng;
    final minLat = a.lat < b.lat ? a.lat : b.lat;
    final maxLat = a.lat > b.lat ? a.lat : b.lat;

    final paddingFactor = 0.2;
    final lngPadding = (maxLng - minLng) * paddingFactor;
    final latPadding = (maxLat - minLat) * paddingFactor;

    final paddedMinLng = minLng - lngPadding;
    final paddedMaxLng = maxLng + lngPadding;
    final paddedMinLat = minLat - latPadding;
    final paddedMaxLat = maxLat + latPadding;

    return mbx.CoordinateBounds(
      southwest: mbx.Point(coordinates: mbx.Position(paddedMinLng, paddedMinLat)),
      northeast: mbx.Point(coordinates: mbx.Position(paddedMaxLng, paddedMaxLat)),
      infiniteBounds: false,
    );
  }

    Future<void> setSource(String input) async {
    if (_map == null || _annotationManager == null) return;

    final pos = _locationService.parseLatLng(input);
    if (pos == null) return;

    if (_sourcePin != null) {
      await _annotationManager!.delete(_sourcePin!);
    }

    _sourcePin = await _annotationManager!.create(
      mbx.PointAnnotationOptions(
        geometry: mbx.Point(coordinates: pos),
        iconImage: 'marker',
        iconSize: 1.2,
      ),
    );

    await _map!.flyTo(
      mbx.CameraOptions(
        center: mbx.Point(coordinates: pos),
        zoom: 14,
      ),
      mbx.MapAnimationOptions(duration: 1500),
    );
  }

  Future<void> setDestination(String input) async {
    if (_map == null || _annotationManager == null) return;

    final pos = _locationService.parseLatLng(input);
    if (pos == null) return;

    if (_destinationPin != null) {
      await _annotationManager!.delete(_destinationPin!);
    }

    _destinationPin = await _annotationManager!.create(
      mbx.PointAnnotationOptions(
        geometry: mbx.Point(coordinates: pos),
        iconImage: 'marker',
        iconSize: 1.2,
      ),
    );

    if (_sourcePin != null) {
      final sourcePos = _sourcePin!.geometry.coordinates;
      final destPos = pos;

      final bounds = _boundsForTwoPoints(sourcePos, destPos);

      final camera = await _map!.cameraForCoordinateBounds(
        bounds,
        mbx.MbxEdgeInsets(top: 100, left: 50, bottom: 100, right: 50),
        null,
        null,
        null,
        null,
      );

      await _map!.flyTo(
        camera,
        mbx.MapAnimationOptions(duration: 1500),
      );
    }
  }

}
