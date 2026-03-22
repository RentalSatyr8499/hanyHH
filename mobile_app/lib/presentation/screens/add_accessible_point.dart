import 'package:flutter/material.dart';
import '../../data/repositories/accessibility_repository.dart';

class AddAccessiblePointScreen extends StatefulWidget {
  const AddAccessiblePointScreen({super.key});

  @override
  State<AddAccessiblePointScreen> createState() =>
      _AddAccessiblePointScreenState();
}

class _AddAccessiblePointScreenState extends State<AddAccessiblePointScreen> {
  String? featureType;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  final AccessibilityRepository accessibilityRepository =
      AccessibilityRepository();

  bool isSubmitting = false;

  Future<void> _submitAccessiblePoint() async {
    final description = descriptionController.text.trim();
    final latitude = double.tryParse(latitudeController.text.trim());
    final longitude = double.tryParse(longitudeController.text.trim());

    if (featureType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a feature type')),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid coordinates')),
      );
      return;
    }

    if (latitude < -90 || latitude > 90) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Latitude must be between -90 and 90')),
      );
      return;
    }

    if (longitude < -180 || longitude > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Longitude must be between -180 and 180')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final result = await accessibilityRepository.reportAccessibilityFeature(
        type: featureType!,
        lat: latitude,
        lng: longitude,
        description: description,
      );

      if (!mounted) return;

      final matchedEdgeMessage = result.matchedEdgeId == null
          ? ''
          : '\nMatched edge: ${result.matchedEdgeId}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.message}$matchedEdgeMessage'),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Accessible Point'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Type of Feature',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: featureType,
                items: const [
                  DropdownMenuItem(
                    value: 'bench',
                    child: Text('Bench'),
                  ),
                  DropdownMenuItem(
                    value: 'ramp',
                    child: Text('Ramp'),
                  ),
                  DropdownMenuItem(
                    value: 'elevator',
                    child: Text('Elevator'),
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
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Example: Bench near Rice Hall entrance',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              const Text(
                'Latitude',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: latitudeController,
                textInputAction: TextInputAction.next,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 38.03258',
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Longitude',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: longitudeController,
                textInputAction: TextInputAction.done,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. -78.510832',
                ),
                onSubmitted: (_) => _submitAccessiblePoint(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitAccessiblePoint,
                  child: Text(
                    isSubmitting ? 'Submitting...' : 'Submit Accessible Point',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}