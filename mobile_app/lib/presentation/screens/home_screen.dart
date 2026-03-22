import 'package:flutter/material.dart';
import '../widgets/map/map_view.dart';
import '../widgets/navigation/navigation_panel.dart';
import '../../../domain/entities/route_request.dart';
import '../../data/repositories/route_repository.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;
import '../../data/services/location_service.dart';

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
  final LocationService locationService = LocationService();

  mbx.MapboxMap? mapController;
  mbx.PointAnnotationManager? annotationManager;
  mbx.PointAnnotation? sourcePin;
  mbx.PointAnnotation? destinationPin;

  void _onSourceChanged(String input) {
    final pos = locationService.parseLatLng(input);
    if (pos == null || mapController == null) return;

    mapController!.flyTo(
      mbx.CameraOptions(
        center: mbx.Point(coordinates: pos),
        zoom: 14,
      ),
      mbx.MapAnimationOptions(
        duration: 1500, // milliseconds
      ),
    );
  }
  void _onDestinationChanged(String input) {
    return;
  }

  void onMapCreated(mbx.MapboxMap controller) {
    mapController = controller;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      annotationManager = await controller.annotations.createPointAnnotationManager();

      controller.setCamera(
        mbx.CameraOptions(
          center: mbx.Point(coordinates: mbx.Position(0, 0)),
          zoom: 1.3,
        ),
      );
    });
  }



  @override
  void initState() {
    super.initState();
    routeRepository = widget.routeRepository;
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
          Expanded(flex: 6, child: MapView(onMapCreated: onMapCreated)),
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
}

