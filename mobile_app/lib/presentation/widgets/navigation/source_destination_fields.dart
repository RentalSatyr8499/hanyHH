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
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Source',
            prefixIcon: Icon(Icons.my_location),
          ),
          onChanged: (value) {
            request.source = value;
            onSourceChanged(value);
          }
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Destination',
            prefixIcon: Icon(Icons.location_on),
          ),
          onChanged: (value) {
            request.destination = value;
            onDestinationChanged(value);
          }
        ),
      ],
    );
  }
}

