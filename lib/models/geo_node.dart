class GeoNode {
  const GeoNode({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.elevation,
    this.tags = const {},
  });

  final int id;
  final double latitude;
  final double longitude;
  final double? elevation;
  final Map<String, String> tags;
}
