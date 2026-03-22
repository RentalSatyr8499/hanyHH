import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

import 'app.dart';

void main() async {
  // 1. Ensure Flutter bindings are ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load your .env file
  await dotenv.load(fileName: ".env");

  // 3. Set the Mapbox Token GLOBALlY
  final token = dotenv.env['MAPBOX_PUBLIC_TOKEN'] ?? "";
  
  // Debug: Check if the token is actually loading
  if (token.isEmpty) {
    print("⚠️ WARNING: Mapbox token is empty. Check your .env file.");
  } else {
    print("✅ Mapbox token loaded (Starts with: ${token.substring(0, 5)})");
    mbx.MapboxOptions.setAccessToken(token);
  }

  runApp(const App());
}