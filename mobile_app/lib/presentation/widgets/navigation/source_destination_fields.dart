import 'package:flutter/material.dart';
import '../../../domain/entities/route_request.dart';

class SourceDestinationFields extends StatelessWidget {
  final RouteRequest request;
  final void Function(String) onSourceChanged;
  final void Function(String) onDestinationChanged;

  const SourceDestinationFields({
    super.key,
    required this.request,
    required this.onSourceChanged,
    required this.onDestinationChanged,
  });

  @override
  Widget build(BuildContext context) {
    const customFont = TextStyle(
      fontFamily: 'CustomFont2',
      fontSize: 16,
    );

    return Column(
      children: [
        TextField(
          style: customFont, // typed text
          decoration: InputDecoration(
            labelText: 'Source',
            labelStyle: customFont, // floating label
            hintStyle: customFont,  // non-floating label
            prefixIcon: const Icon(Icons.my_location),
          ),
          onChanged: (value) {
            request.source = value;
            onSourceChanged(value);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          style: customFont,
          decoration: InputDecoration(
            labelText: 'Destination',
            labelStyle: customFont,
            hintStyle: customFont,
            prefixIcon: const Icon(Icons.location_on),
          ),
          onChanged: (value) {
            request.destination = value;
            onDestinationChanged(value);
          },
        ),
      ],
    );
  }
}
