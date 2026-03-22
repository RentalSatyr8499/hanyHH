import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

import '../widgets/map/map_view.dart';
import '../widgets/navigation/navigation_panel.dart';
import '../map/app_map_controller.dart';
import 'add_accessible_point.dart';

import '../../../domain/entities/route_request.dart';
import '../../data/repositories/route_repository.dart';

import '../widgets/navigation/map_navigation_service.dart';
import '../widgets/navigation/navigation_mode.dart' as nm;
import '../widgets/navigation/navigation_controller.dart';
import '../widgets/navigation/navigation_overlays.dart';
import 'package:audioplayers/audioplayers.dart';

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
  final AudioPlayer _player = AudioPlayer();

  nm.NavigationMode mode = nm.NavigationMode.idle;
  final NavigationController navController = NavigationController();
  MapNavigationService? navMap;

  @override
  void initState() {
    super.initState();
    routeRepository = widget.routeRepository;
  }

  void _onMapCreated(mbx.MapboxMap controller) {
    mapController.init(controller);
    navMap = MapNavigationService(controller);
  }

  void _onSourceChanged(String input) {
    setState(() {
      request.source = input;
    });
    mapController.setSource(input);
  }

  void _onDestinationChanged(String input) {
    setState(() {
      request.destination = input;
    });
    mapController.setDestination(input);
  }

  Future<void> _onFindRoutePressed() async {
    if (request.source == null ||
        request.source!.trim().isEmpty ||
        request.destination == null ||
        request.destination!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both source and destination'),
        ),
      );
      return;
    }
    
    _player.play(AssetSource('find-route.mp3'));

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

    mapController.drawRoute(route.toPositions());

    setState(() {
      navController.setRoute(route);
      mode = nm.NavigationMode.routeReady;
    });
  }

  Future<void> _startNavigation() async {
  // 1. Update the UI mode immediately to show the banner and buttons
  setState(() {
    mode = nm.NavigationMode.navigating;
  });

  // 2. Prepare the camera
  // We use the 'geometryForNavigation' to get the current point 
  // AND the look-ahead point for the bearing.
  if (navMap != null) {
    await navMap!.enterNavigationTilt(); // Sets pitch to 60.0
    await navMap!.moveToStep(navController.geometryForNavigation);
  }
}

  Future<void> _nextStep() async {
  navController.nextStep();
    // Use the new getter that includes the "look-ahead" point
    await navMap?.moveToStep(navController.geometryForNavigation);
    setState(() {});
  }

  Future<void> _endNavigation() async {
    await navMap?.resetTilt();

    setState(() {
      mode = nm.NavigationMode.idle;
    });
  }

  void _openAddAccessiblePointScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddAccessiblePointScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
      top: false,
      bottom: false,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: mode == nm.NavigationMode.navigating ? 10 : 6,
                child: MapView(onMapCreated: _onMapCreated),
              ),

              if (mode != nm.NavigationMode.navigating)
                Expanded(
                  flex: 4,
                  child: NavigationPanel(
                    request: request,
                    onFindRoute: _onFindRoutePressed,
                    onAddAccessiblePoint: _openAddAccessiblePointScreen,
                    onSourceChanged: _onSourceChanged,
                    onDestinationChanged: _onDestinationChanged,
                  ),
                ),
            ],
          ),

          // BEGIN ROUTE BUTTON
          if (mode == nm.NavigationMode.routeReady)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45, // ~middle of screen
              left: 20,
              right: 20,
              child: BeginRouteButton(onPressed: _startNavigation),
            ),

          // INSTRUCTION BANNER
          if (mode == nm.NavigationMode.navigating)
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: InstructionBanner(
                text: navController.currentInstruction,
              ),
            ),

          // NEXT STEP BUTTON
          if (mode == nm.NavigationMode.navigating)
            Positioned(
              bottom: 100,
              left: 40,
              child: NextStepButton(onPressed: _nextStep),
            ),

          // END ROUTE BUTTON
          if (mode == nm.NavigationMode.navigating)
            Positioned(
              bottom: 100,
              right: 40,
              child: EndRouteButton(onPressed: _endNavigation),
            ),
          ],
        ),
      )
    );
  }
}