enum RouteProfile {
  hiking,
  cycling,
  running;

  String get label {
    switch (this) {
      case RouteProfile.hiking:
        return 'hiking';
      case RouteProfile.cycling:
        return 'cycling';
      case RouteProfile.running:
        return 'running';
    }
  }

  List<String> get routeValues {
    switch (this) {
      case RouteProfile.hiking:
        return const ['hiking', 'foot'];
      case RouteProfile.cycling:
        return const ['bicycle', 'mtb'];
      case RouteProfile.running:
        return const ['running', 'foot', 'jogging'];
    }
  }

  List<String> get highwayValues {
    switch (this) {
      case RouteProfile.hiking:
        return const [
          'path',
          'footway',
          'track',
          'steps',
          'pedestrian',
          'living_street',
          'service',
          'residential',
          'unclassified',
        ];
      case RouteProfile.cycling:
        return const [
          'cycleway',
          'path',
          'track',
          'service',
          'residential',
          'living_street',
          'unclassified',
          'tertiary',
          'secondary',
        ];
      case RouteProfile.running:
        return const [
          'path',
          'footway',
          'track',
          'pedestrian',
          'living_street',
          'service',
          'residential',
          'unclassified',
        ];
    }
  }

  double get maxRecommendedDistanceKm {
    switch (this) {
      case RouteProfile.hiking:
        return 20;
      case RouteProfile.cycling:
        return 60;
      case RouteProfile.running:
        return 15;
    }
  }
}
