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
      _showSnackBar('Please select a feature type');
      return;
    }

    if (description.isEmpty) {
      _showSnackBar('Please enter a description');
      return;
    }

    if (latitude == null || longitude == null) {
      _showSnackBar('Please enter valid coordinates');
      return;
    }

    if (latitude < -90 || latitude > 90) {
      _showSnackBar('Latitude must be between -90 and 90');
      return;
    }

    if (longitude < -180 || longitude > 180) {
      _showSnackBar('Longitude must be between -180 and 180');
      return;
    }

    setState(() => isSubmitting = true);

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

      _showSnackBar('${result.message}$matchedEdgeMessage');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Submission failed: $e');
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
    const labelStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: 0.8,
    );

    const fieldTextStyle = TextStyle(
      fontSize: 18,
      color: Colors.white,
      height: 1.2,
    );

    const hintTextStyle = TextStyle(
      fontSize: 17,
      color: Colors.white,
      height: 1.2,
    );

    InputDecoration themedDecoration(String hintText) {
      return InputDecoration(
        hintText: hintText.isEmpty ? null : hintText,
        hintStyle: hintTextStyle,
        filled: true,
        fillColor: Colors.black.withOpacity(0.35),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white70, width: 1.6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true, // Key fix: allows content to flow to the very bottom
      appBar: AppBar(
        title: const Text(
          'Add Accessible Point',
          style: TextStyle(
            fontFamily: 'CustomFont2',
            fontSize: 26,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
      ),
      body: Container(
        // The background container now fills the entire screen
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/wood-background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.22),
          child: SingleChildScrollView(
            // Key fix: Wrap internal content in SafeArea, not the whole body
            child: SafeArea(
              bottom: true, 
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text('TYPE OF FEATURE', style: labelStyle),
                    const SizedBox(height: 10),
                    Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: const Color(0xFF4B2E1F),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: featureType,
                        dropdownColor: const Color(0xFF4B2E1F),
                        style: fieldTextStyle,
                        iconEnabledColor: Colors.white,
                        hint: const Text('Select a feature', style: hintTextStyle),
                        items: const [
                          DropdownMenuItem(value: 'bench', child: Text('Bench', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'ramp', child: Text('Ramp', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'elevator', child: Text('Elevator', style: TextStyle(color: Colors.white))),
                        ],
                        onChanged: (value) => setState(() => featureType = value),
                        decoration: themedDecoration(''),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('DESCRIPTION', style: labelStyle),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      style: fieldTextStyle,
                      textInputAction: TextInputAction.next,
                      decoration: themedDecoration('Example: Bench near Rice Hall entrance'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    const Text('LATITUDE', style: labelStyle),
                    const SizedBox(height: 10),
                    TextField(
                      controller: latitudeController,
                      style: fieldTextStyle,
                      textInputAction: TextInputAction.next,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: themedDecoration('e.g. 38.03258'),
                    ),
                    const SizedBox(height: 24),
                    const Text('LONGITUDE', style: labelStyle),
                    const SizedBox(height: 10),
                    TextField(
                      controller: longitudeController,
                      style: fieldTextStyle,
                      textInputAction: TextInputAction.done,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: themedDecoration('e.g. -78.510832'),
                      onSubmitted: (_) => _submitAccessiblePoint(),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: _WoodSubmitButton(
                        label: isSubmitting ? 'Submitting...' : 'Submit point',
                        onTap: isSubmitting ? null : _submitAccessiblePoint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WoodSubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _WoodSubmitButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.7 : 1,
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: SizedBox(
            width: 270,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Image.asset('assets/wood-plank.png', fit: BoxFit.fill),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'CustomFont1',
                    fontSize: 50,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E1E12),
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}