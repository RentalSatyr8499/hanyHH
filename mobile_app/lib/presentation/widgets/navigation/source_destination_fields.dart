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
        _LocationField(
          icon: Icons.my_location,
          label: 'SOURCE:',
          value: request.source ?? '',
          onChanged: onSourceChanged,
        ),
        const SizedBox(height: 22),
        _LocationField(
          icon: Icons.location_on,
          label: 'DESTINATION:',
          value: request.destination ?? '',
          onChanged: onDestinationChanged,
        ),
      ],
    );
  }
}

class _LocationField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _LocationField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const labelStyle = TextStyle(
      fontFamily: 'CustomFont2',
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.0,
    );

    const valueStyle = TextStyle(
      fontFamily: 'CustomFont2',
      color: Colors.white,
      fontSize: 18,
      height: 1.2,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Icon(
            icon,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: labelStyle),
              const SizedBox(height: 4),
              TextFormField(
                initialValue: value,
                onChanged: onChanged,
                cursorColor: Colors.white,
                style: valueStyle,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white70,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white70,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}