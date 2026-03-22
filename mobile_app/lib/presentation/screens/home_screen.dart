import 'package:flutter/material.dart';
import '../widgets/map/map_view.dart';
import '../widgets/navigation/navigation_panel.dart';
import '../../../domain/entities/route_request.dart';
import '../../data/repositories/route_repository.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;
import '../../data/services/location_service.dart';
import 'package:flutter/services.dart';   // for rootBundle, ByteData
import '../map/app_map_controller.dart';


class HomeScreen extends StatefulWidget {
  final RouteRepository routeRepository;

  const HomeScreen({
    super.key,
    required this.routeRepository,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final RouteRequest request = RouteRequest();
  late final RouteRepository routeRepository;
  final AppMapController mapController = AppMapController();

  @override
  void initState() {
    super.initState();
    routeRepository = widget.routeRepository;
  }
  
  void _onMapCreated(mbx.MapboxMap controller) {
    mapController.init(controller);
  }
  void _onSourceChanged(String input) {
    request.source = input;
    mapController.setSource(input);
  }

  void _onDestinationChanged(String input) {
    request.destination = input;
    mapController.setDestination(input);
  }

  void _onFindRoutePressed() async {
    final route = await routeRepository.getRoute(
      request.source!,
      request.destination!,
      {
        "avoid_stairs": request.avoidStairs,
        "wheelchair_only": request.wheelchairOnly,
        "need_benches": request.needBenches,
        "max_route_time_minutes": request.maxRouteTimeMinutes,
      },
    );

    // TODO: draw route on map
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(flex: 6, child: MapView(onMapCreated: _onMapCreated)),
          Expanded(
            flex: 4,
            child: NavigationPanel(
              request: request,
              onFindRoute: _onFindRoutePressed,
              onSourceChanged: _onSourceChanged,
              onDestinationChanged: _onDestinationChanged,
            ),
          ),
        ],
      ),
    );
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

}

