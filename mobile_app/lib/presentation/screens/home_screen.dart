import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Hello, Accessible World!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),

            // Button 1
            ElevatedButton(
              onPressed: () {
                // TODO: Add navigation or action
              },
              child: const Text('Find Accessible Route'),
            ),

            const SizedBox(height: 16),

            // Button 2
            ElevatedButton(
              onPressed: () {
                // TODO: Add navigation or action
              },
              child: const Text('Add Accessible Point'),
            ),
          ],
        ),
      ),
    );
  }
}
