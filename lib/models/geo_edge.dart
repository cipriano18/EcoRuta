import 'package:ecoruta/models/geo_node.dart';
import 'package:ecoruta/models/route_profile.dart';

class GeoEdge {
  const GeoEdge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.distanceMeters,
    required this.profile,
    this.name,
    this.sourceWayId,
    this.tags = const {},
    this.geometry = const [],
  });

  final String id;
  final int fromNodeId;
  final int toNodeId;
  final double distanceMeters;
  final RouteProfile profile;
  final String? name;
  final int? sourceWayId;
  final Map<String, String> tags;
  final List<GeoNode> geometry;
}
