import 'package:flutter/material.dart';

class BeginRouteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const BeginRouteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.blue,
      ),
      onPressed: onPressed,
      child: const Text("Begin Route"),
    );
  }
}

class InstructionBanner extends StatelessWidget {
  final String text;
  const InstructionBanner({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}

class NextStepButton extends StatelessWidget {
  final VoidCallback onPressed;
  const NextStepButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.green,
      onPressed: onPressed,
      child: const Icon(Icons.arrow_forward),
    );
  }
}

class EndRouteButton extends StatelessWidget {
  final VoidCallback onPressed;
  const EndRouteButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: onPressed,
      child: const Icon(Icons.stop),
    );
  }
}
