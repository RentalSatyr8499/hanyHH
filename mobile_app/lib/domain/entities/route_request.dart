class RouteRequest {
  String? source;
  String? destination;

  bool avoidStairs = false;
  bool wheelchairOnly = false;
  bool needBenches = false;
  double maxRouteTimeMinutes = 20;

  RouteRequest();
}
