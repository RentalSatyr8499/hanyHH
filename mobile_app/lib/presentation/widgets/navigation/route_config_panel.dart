import 'package:flutter/material.dart';
import '../../../domain/entities/route_request.dart';

class RouteConfigPanel extends StatefulWidget {
  final RouteRequest request;

  const RouteConfigPanel({super.key, required this.request});

  @override
  State<RouteConfigPanel> createState() => _RouteConfigPanelState();
}

class _RouteConfigPanelState extends State<RouteConfigPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('No stairs'),
          value: widget.request.avoidStairs,
          onChanged: (value) {
            setState(() => widget.request.avoidStairs = value!);
          },
        ),
        CheckboxListTile(
          title: const Text('Wheelchair only'),
          value: widget.request.wheelchairOnly,
          onChanged: (value) {
            setState(() => widget.request.wheelchairOnly = value!);
          },
        ),
        CheckboxListTile(
          title: const Text('Need benches'),
          value: widget.request.needBenches,
          onChanged: (value) {
            setState(() => widget.request.needBenches = value!);
          },
        ),
        CheckboxListTile(
          title: const Text('Indoor only'),
          value: widget.request.indoorOnly,
          onChanged: (value) {
            setState(() => widget.request.indoorOnly = value!);
          },
        ),
      ],
    );
  }
}

