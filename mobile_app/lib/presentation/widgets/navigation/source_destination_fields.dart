import 'package:flutter/material.dart';

class SourceDestinationFields extends StatelessWidget {
  const SourceDestinationFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        TextField(
          decoration: InputDecoration(
            labelText: 'Source',
            prefixIcon: Icon(Icons.my_location),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Destination',
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
      ],
    );
  }
}
