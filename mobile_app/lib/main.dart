import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final token = dotenv.env['MAPBOX_PUBLIC_TOKEN'] ?? '';

  if (token.isEmpty) {
    debugPrint('⚠️ WARNING: Mapbox token is empty. Check your .env file.');
  } else {
    debugPrint('✅ Mapbox token loaded (starts with: ${token.substring(0, 5)})');
    mbx.MapboxOptions.setAccessToken(token);
  }

  runApp(const App());
}
