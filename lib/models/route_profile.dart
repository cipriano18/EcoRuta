enum RouteProfile {
  hiking,
  cycling;

  String get label {
    switch (this) {
      case RouteProfile.hiking:
        return 'hiking';
      case RouteProfile.cycling:
        return 'cycling';
    }
  }

  List<String> get routeValues {
    switch (this) {
      case RouteProfile.hiking:
        return const ['hiking', 'foot'];
      case RouteProfile.cycling:
        return const ['bicycle', 'mtb'];
    }
  }

  List<String> get highwayValues {
    switch (this) {
      case RouteProfile.hiking:
        return const ['path', 'footway', 'track', 'steps'];
      case RouteProfile.cycling:
        return const ['cycleway', 'path', 'track', 'service', 'residential'];
    }
  }
}
