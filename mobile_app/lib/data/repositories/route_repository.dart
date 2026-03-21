import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route.dart';

class RouteRepository {
  final String baseUrl;

  RouteRepository(this.baseUrl);

  Future<RouteModel> getRoute(
    Map<String, double> source,
    Map<String, double> destination,
    Map<String, dynamic> preferences,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/route'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "source": source,
        "destination": destination,
        "preferences": preferences,
      }),
    );

    final json = jsonDecode(response.body);
    return RouteModel.fromJson(json['route']);
  }
}
