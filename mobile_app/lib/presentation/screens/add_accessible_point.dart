import 'package:flutter/material.dart';

class AddAccessiblePointScreen extends StatefulWidget {
  const AddAccessiblePointScreen({super.key});

  @override
  State<AddAccessiblePointScreen> createState() =>
      _AddAccessiblePointScreenState();
}

class _AddAccessiblePointScreenState extends State<AddAccessiblePointScreen> {
  String? featureType;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Accessible Point'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feature type dropdown
            const Text(
              'Type of Feature',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: featureType,
              items: const [
                DropdownMenuItem(
                  value: 'ramp',
                  child: Text('Wheelchair Ramp'),
                ),
                DropdownMenuItem(
                  value: 'elevator',
                  child: Text('Elevator'),
                ),
                DropdownMenuItem(
                  value: 'automatic_door',
                  child: Text('Automatic Door'),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text('Other'),
                ),
                DropdownMenuItem(
                  value: 'stairs',
                  child: Text('stairs'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  featureType = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select a feature',
              ),
            ),

            const SizedBox(height: 24),

            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe the accessibility feature',
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Notes
            const Text(
              'Additional Notes (optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Anything else helpful?',
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Location button
            FilledButton(
              onPressed: () {
                // TODO: Hook up location picker or GPS
              },
              child: const Text('Use Current Location'),
            ),

            const Spacer(),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Submit to backend / Firestore
                },
                child: const Text('Submit Accessible Point'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
