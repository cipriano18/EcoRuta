import 'package:ecoruta/models/geo_node.dart';

class RouteResult {
  const RouteResult({
    required this.path,
    required this.totalDistanceMeters,
    required this.estimatedDurationSeconds,
    this.elevationGainMeters = 0,
  });

  final List<GeoNode> path;
  final double totalDistanceMeters;
  final int estimatedDurationSeconds;
  final double elevationGainMeters;

  bool get isEmpty => path.isEmpty;

  String get formattedDistance {
    if (totalDistanceMeters >= 1000) {
      return '${(totalDistanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${totalDistanceMeters.round()} m';
  }

  String get formattedDuration {
    final hours = estimatedDurationSeconds ~/ 3600;
    final minutes = (estimatedDurationSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes}m';
  }

  String get formattedElevationGain => '+${elevationGainMeters.round()} m';

  RouteResult withElevation(List<GeoNode> enrichedPath) {
    return RouteResult(
      path: enrichedPath,
      totalDistanceMeters: totalDistanceMeters,
      estimatedDurationSeconds: estimatedDurationSeconds,
      elevationGainMeters: _calculateElevationGain(enrichedPath),
    );
  }

  static double _calculateElevationGain(List<GeoNode> path) {
    double gain = 0;
    for (var i = 1; i < path.length; i++) {
      final prev = path[i - 1].elevation;
      final curr = path[i].elevation;
      if (prev != null && curr != null) {
        final diff = curr - prev;
        if (diff > 0) gain += diff;
      }
    }
    return gain;
  }
}
