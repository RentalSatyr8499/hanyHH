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
    const labelStyle = TextStyle(
      fontFamily: 'CustomFont2',
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

    const borderColor = Colors.white70;

    InputDecoration themedDecoration(String hintText) {
      return InputDecoration(
        hintText: hintText.isEmpty ? null : hintText,
        hintStyle: hintTextStyle,
        filled: true,
        fillColor: Colors.black.withOpacity(0.35),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: borderColor,
            width: 1.6,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: borderColor,
            width: 1.6,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
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
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 30,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/wood-background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.22),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  const Text(
                    'TYPE OF FEATURE',
                    style: labelStyle,
                  ),
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
                      hint: const Text(
                        'Select a feature',
                        style: hintTextStyle,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'bench',
                          child: Text(
                            'Bench',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'ramp',
                          child: Text(
                            'Ramp',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'elevator',
                          child: Text(
                            'Elevator',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          featureType = value;
                        });
                      },
                      decoration: themedDecoration(''),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'DESCRIPTION',
                    style: labelStyle,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    style: fieldTextStyle,
                    textInputAction: TextInputAction.next,
                    decoration: themedDecoration(
                      'Example: Bench near Rice Hall entrance',
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'LATITUDE',
                    style: labelStyle,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: latitudeController,
                    style: fieldTextStyle,
                    textInputAction: TextInputAction.next,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: themedDecoration('e.g. 38.03258'),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'LONGITUDE',
                    style: labelStyle,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: longitudeController,
                    style: fieldTextStyle,
                    textInputAction: TextInputAction.done,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: themedDecoration('e.g. -78.510832'),
                    onSubmitted: (_) => _submitAccessiblePoint(),
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: _WoodSubmitButton(
                      label: isSubmitting ? 'SUBMITTING...' : 'SUBMIT POINT',
                      onTap: isSubmitting ? null : _submitAccessiblePoint,
                    ),
                  ),
                ],
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

  const _WoodSubmitButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.7 : 1,
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SizedBox(
            width: 270,
            height: 76,
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
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'CustomFont2',
                    fontSize: 24,
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