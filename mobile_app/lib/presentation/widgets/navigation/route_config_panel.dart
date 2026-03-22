import 'package:flutter/material.dart';
import '../../../domain/entities/route_request.dart';

class RouteConfigPanel extends StatefulWidget {
  final RouteRequest request;

  const RouteConfigPanel({
    super.key,
    required this.request,
  });

  @override
  State<RouteConfigPanel> createState() => _RouteConfigPanelState();
}

class _RouteConfigPanelState extends State<RouteConfigPanel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ConfigOptionRow(
          label: 'No stairs',
          value: widget.request.avoidStairs,
          onTap: () {
            setState(() {
              widget.request.avoidStairs = !widget.request.avoidStairs;
            });
          },
        ),
        const SizedBox(height: 18),
        _ConfigOptionRow(
          label: 'Wheelchair\nonly',
          value: widget.request.wheelchairOnly,
          onTap: () {
            setState(() {
              widget.request.wheelchairOnly = !widget.request.wheelchairOnly;
            });
          },
        ),
        const SizedBox(height: 18),
        _ConfigOptionRow(
          label: 'Need\nbenches',
          value: widget.request.needBenches,
          onTap: () {
            setState(() {
              widget.request.needBenches = !widget.request.needBenches;
            });
          },
        ),
        const SizedBox(height: 18),
        _ConfigOptionRow(
          label: 'Indoor only',
          value: widget.request.indoorOnly,
          onTap: () {
            setState(() {
              widget.request.indoorOnly = !widget.request.indoorOnly;
            });
          },
        ),
      ],
    );
  }
}

class _ConfigOptionRow extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onTap;

  const _ConfigOptionRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontFamily: 'CustomFont2',
      color: Colors.white,
      fontSize: 18,
      height: 1.2,
    );

    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: textStyle,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: value
                ? const Center(
                    child: Icon(
                      Icons.circle,
                      size: 12,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}