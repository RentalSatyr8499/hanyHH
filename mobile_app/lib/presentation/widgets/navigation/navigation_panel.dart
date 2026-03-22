import 'package:flutter/material.dart';
import 'source_destination_fields.dart';
import 'route_config_panel.dart';
import '../../../domain/entities/route_request.dart';

class NavigationPanel extends StatelessWidget {
  final RouteRequest request;
  final VoidCallback onFindRoute;

  final void Function(String) onSourceChanged;
  final void Function(String) onDestinationChanged;

  const NavigationPanel({
    super.key,
    required this.request,
    required this.onFindRoute,
    required this.onSourceChanged,
    required this.onDestinationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/wood-background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SourceDestinationFields(
                    request: request,
                    onSourceChanged: onSourceChanged,
                    onDestinationChanged: onDestinationChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: RouteConfigPanel(request: request),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onFindRoute,
            child: const Text("Find Accessible Route"),
          ),
        ],
      ),
    );
  }
}
