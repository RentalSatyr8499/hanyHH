import '../../../data/models/route.dart';

class NavigationController {
  late RouteModel route;
  int currentStepIndex = 0;

  void setRoute(RouteModel r) {
    route = r;
    currentStepIndex = 0;
  }

  bool get hasNextStep =>
      currentStepIndex < route.steps.length - 1;

  void nextStep() {
    if (hasNextStep) {
      currentStepIndex++;
    }
  }

  String get currentInstruction =>
      route.steps[currentStepIndex].instruction;

  List<List<double>> get currentStepGeometry =>
      route.steps[currentStepIndex].geometry.coordinates;

  /// Returns the coordinates for the current step AND the first point 
  /// of the following step so the camera knows which way to face.
  List<List<double>> get geometryForNavigation {
    List<List<double>> currentCoords = List.from(route.steps[currentStepIndex].geometry.coordinates);
    
    // If there's a next step, peek at its first coordinate to determine bearing
    if (hasNextStep) {
      final nextCoords = route.steps[currentStepIndex + 1].geometry.coordinates;
      if (nextCoords.isNotEmpty) {
        currentCoords.add(nextCoords.first);
      }
    }
    return currentCoords;
  }
}
