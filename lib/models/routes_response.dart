class RoutesResponse {
  final List<Route> routes;

  RoutesResponse({required this.routes});

  // Factory constructor to create an instance from JSON
  factory RoutesResponse.fromJson(Map<String, dynamic> json) {
    return RoutesResponse(
      routes: (json['routes'] as List<dynamic>)
          .map((route) => Route.fromJson(route))
          .toList(),
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'routes': routes.map((route) => route.toJson()).toList(),
    };
  }
}

class Route {
  final String duration;

  Route({required this.duration});

  // Factory constructor to create an instance from JSON
  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      duration: json['duration'] as String,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'duration': duration,
    };
  }
}