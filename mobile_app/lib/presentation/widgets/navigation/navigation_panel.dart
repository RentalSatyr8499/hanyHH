import 'package:flutter/material.dart';
import 'source_destination_fields.dart';
import 'route_config_panel.dart';

class NavigationPanel extends StatelessWidget {
  const NavigationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: SourceDestinationFields(),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: RouteConfigPanel(),
          ),
        ],
      ),
    );
  }
}
