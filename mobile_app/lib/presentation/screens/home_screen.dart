import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  mbx.MapboxMap? _mapboxMap;

  // ✅ Hardcoded location (Charlottesville, VA)
  final mbx.CameraOptions _camera = mbx.CameraOptions(
    center: mbx.Point(
      coordinates: mbx.Position(-78.4767, 38.0293),
    ),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mbx.MapWidget(
        key: const ValueKey("mapWidget"),
        // Add this line below!
        styleUri: mbx.MapboxStyles.MAPBOX_STREETS, 
        onMapLoadErrorListener: (error) {
          print("❌ Mapbox Load Error: ${error.type} - ${error.message}");
        },
        cameraOptions: _camera,
        onMapCreated: (mapboxMap) async {
          _mapboxMap = mapboxMap;
          print("✅ Map created. Attempting to load style...");
  
          // Manually trigger the style load
          await mapboxMap.loadStyleURI(mbx.MapboxStyles.MAPBOX_STREETS);
          print("🎨 Style load command sent.");
        },
      ),
    );
  }
}