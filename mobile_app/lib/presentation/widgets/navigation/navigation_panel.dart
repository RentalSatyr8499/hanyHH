import 'package:flutter/material.dart';
import 'source_destination_fields.dart';
import 'route_config_panel.dart';
import '../../../domain/entities/route_request.dart';

class NavigationPanel extends StatelessWidget {
  final RouteRequest request;
  final VoidCallback onFindRoute;
  final VoidCallback onAddAccessiblePoint;
  final void Function(String) onSourceChanged;
  final void Function(String) onDestinationChanged;

  const NavigationPanel({
    super.key,
    required this.request,
    required this.onFindRoute,
    required this.onAddAccessiblePoint,
    required this.onSourceChanged,
    required this.onDestinationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/wood-background.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top content scrolls if needed (prevents overflow)
            Expanded(
              child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
            ),

            const SizedBox(height: 1),

            // Buttons row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Center(
                    child: _WoodButton(
                      label: 'FIND ROUTE',
                      width: 240,
                      height: 72,
                      fontSize: 28,
                      onTap: onFindRoute,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _WoodPlusButton(
                  onTap: onAddAccessiblePoint,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WoodButton extends StatelessWidget {
  final String label;
  final double width;
  final double height;
  final double fontSize;
  final VoidCallback onTap;

  const _WoodButton({
    required this.label,
    required this.width,
    required this.height,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/wood-plank.png',
                fit: BoxFit.fill,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'CustomFont2',
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E1E12),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WoodPlusButton extends StatelessWidget {
  final VoidCallback onTap;

  const _WoodPlusButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 56,
        height: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/wood-plank.png',
                  fit: BoxFit.cover,
                ),
              ),
              const Text(
                '+',
                style: TextStyle(
                  fontFamily: 'CustomFont2',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E1E12),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}