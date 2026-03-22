import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RouteRepository {
  final String baseUrl;

  RouteRepository({required this.baseUrl});

  Future<Map<String, double>> _geocode(String query) async {
    final accessToken = dotenv.env['MAPBOX_PUBLIC_TOKEN'] ?? "";

    if (accessToken.isEmpty) {
      throw Exception("Mapbox token missing — check your .env file.");
    }

    final url = Uri.parse(
      "https://api.mapbox.com/search/geocode/v6/forward"
      "?q=${Uri.encodeComponent(query)}"
      "&access_token=$accessToken"
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Geocoding failed: ${response.body}");
    }

    final json = jsonDecode(response.body);

    final coords = json["features"][0]["geometry"]["coordinates"];
    final lng = coords[0];
    final lat = coords[1];

    return {"lat": lat, "lng": lng};
  }

  Map<String, double> _parseLatLng(String input) {
    final parts = input.split(',');

    if (parts.length != 2) {
      throw Exception("Invalid coordinate format. Use: lat, lng");
    }

    final lat = double.parse(parts[0].trim());
    final lng = double.parse(parts[1].trim());

    return {"lat": lat, "lng": lng};
  }

  Future<RouteModel> getRoute(
    String sourceText,
    String destinationText,
    Map<String, dynamic> preferences,
  ) async {
    // 1. Convert text → coordinates
    final sourceCoords = await _parseLatLng(sourceText);
    final destinationCoords = await _parseLatLng(destinationText);

    final body = jsonEncode({
      "source": sourceCoords,
      "destination": destinationCoords,
      "preferences": preferences,
    });

    // 2. Send coordinates to your backend
    final response = await http.post(
      Uri.parse('$baseUrl/route'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "source": sourceCoords,
        "destination": destinationCoords,
        "preferences": preferences,
      }),
    );

    print("BACKEND RESPONSE BODY: ${response.body}");
    
    final json = jsonDecode(response.body);
    return RouteModel.fromJson(json['route']);

  }

}
