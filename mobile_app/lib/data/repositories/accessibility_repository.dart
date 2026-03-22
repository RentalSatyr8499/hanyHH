import 'dart:convert';
import 'package:http/http.dart' as http;

class AccessibilityRepository {
  static const String reportFeatureUrl =
    'http://127.0.0.1:5001/hany-hh/us-central1/report_accessibility_feature';

  Future<AccessibilityReportResult> reportAccessibilityFeature({
    required String type,
    required double lat,
    required double lng,
    required String description,
  }) async {
    final uri = Uri.parse(reportFeatureUrl);

    final requestBody = {
      'feature': {
        'type': type,
        'lat': lat,
        'lng': lng,
        'description': description,
      }
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    Map<String, dynamic> decodedBody = {};
    if (response.body.isNotEmpty) {
      decodedBody = jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMessage =
          decodedBody['error']?.toString() ??
          decodedBody['message']?.toString() ??
          'Request failed with status ${response.statusCode}';
      throw Exception(errorMessage);
    }

    return AccessibilityReportResult.fromJson(decodedBody);
  }
}

class AccessibilityReportResult {
  final String message;
  final String? reportId;
  final String? matchedEdgeId;

  AccessibilityReportResult({
    required this.message,
    this.reportId,
    this.matchedEdgeId,
  });

  factory AccessibilityReportResult.fromJson(Map<String, dynamic> json) {
    return AccessibilityReportResult(
      message: json['message']?.toString() ?? 'Success',
      reportId: json['reportId']?.toString(),
      matchedEdgeId: json['matchedEdgeId']?.toString(),
    );
  }
}