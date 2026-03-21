import 'package:flutter/material.dart';

class RouteConfigPanel extends StatelessWidget {
  const RouteConfigPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('No stairs'),
          value: true,
          onChanged: (_) {},
        ),
        CheckboxListTile(
          title: const Text('Wheelchair only'),
          value: false,
          onChanged: (_) {},
        ),
        CheckboxListTile(
          title: const Text('Need benches'),
          value: false,
          onChanged: (_) {},
        ),
        const SizedBox(height: 12),
        const Text('Max route time (minutes)'),
        Slider(
          value: 20,
          min: 5,
          max: 60,
          onChanged: (_) {},
        ),
      ],
    );
  }
}
