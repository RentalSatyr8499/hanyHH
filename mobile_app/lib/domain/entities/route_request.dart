class RouteRequest {
  String? source;
  String? destination;

  bool avoidStairs = false;
  bool wheelchairOnly = false;
  bool needBenches = false;
  bool indoorOnly = false;
  double maxRouteTimeMinutes = 20;
}
