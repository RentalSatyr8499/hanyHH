import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

class MapCameraService {
  mbx.CoordinateBounds boundsForTwoPoints(mbx.Position a, mbx.Position b) {
    final minLng = a.lng < b.lng ? a.lng : b.lng;
    final maxLng = a.lng > b.lng ? a.lng : b.lng;
    final minLat = a.lat < b.lat ? a.lat : b.lat;
    final maxLat = a.lat > b.lat ? a.lat : b.lat;

    const paddingFactor = 0.2;
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

  Future<void> flyToPosition(mbx.MapboxMap map, mbx.Position pos) async {
    await map.flyTo(
      mbx.CameraOptions(
        center: mbx.Point(coordinates: pos),
        zoom: 14,
      ),
      mbx.MapAnimationOptions(duration: 1500),
    );
  }

  Future<void> fitTwoPoints(mbx.MapboxMap map, mbx.Position a, mbx.Position b) async {
    final bounds = boundsForTwoPoints(a, b);

    final camera = await map.cameraForCoordinateBounds(
      bounds,
      mbx.MbxEdgeInsets(top: 100, left: 50, bottom: 100, right: 50),
      null,
      null,
      null,
      null,
    );

    await map.flyTo(
      camera,
      mbx.MapAnimationOptions(duration: 1500),
    );
  }
}
