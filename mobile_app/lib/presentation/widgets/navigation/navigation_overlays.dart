import 'package:flutter/material.dart';

/// ------------------------------------------------------------
/// WOOD BUTTON (unchanged except for font + styling)
/// ------------------------------------------------------------
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
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 600),
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
                  fontFamily: 'CustomFont1',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2E1E12),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// BEGIN ROUTE BUTTON (wood + centered in middle of screen)
/// ------------------------------------------------------------
class BeginRouteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const BeginRouteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return _WoodButton(
      label: "Begin Route",
      width: 240,
      height: 80,
      fontSize: 50,
      onTap: onPressed,
    );
  }
}

/// ------------------------------------------------------------
/// INSTRUCTION BANNER (centered + large text + fade transitions)
/// ------------------------------------------------------------
class InstructionBanner extends StatelessWidget {
  final String text;
  const InstructionBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: Container(
        key: ValueKey(text),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28, // larger
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// NEXT STEP BUTTON (keep original FAB style, just change label)
/// ------------------------------------------------------------
class NextStepButton extends StatelessWidget {
  final VoidCallback onPressed;
  const NextStepButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 600),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green,
            onPressed: onPressed,
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}


/// ------------------------------------------------------------
/// END ROUTE BUTTON (keep original FAB style, icon only)
/// ------------------------------------------------------------
class EndRouteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const EndRouteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 600),
      child: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: onPressed,
        child: const Icon(Icons.stop),
      ),
    );
  }
}
