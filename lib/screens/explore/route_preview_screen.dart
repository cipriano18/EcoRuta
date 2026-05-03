import 'package:ecoruta/models/geo_node.dart';
import 'package:ecoruta/services/routing/route_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RoutePreviewScreen extends StatelessWidget {
  const RoutePreviewScreen({
    super.key,
    required this.title,
    required this.route,
  });

  final String title;
  final RouteResult route;

  static const _primaryColor = Color(0xFF012D1D);
  static const _accentColor = Color(0xFFFF7043);

  @override
  Widget build(BuildContext context) {
    final points = route.path
        .map((node) => LatLng(node.latitude, node.longitude))
        .toList(growable: false);
    final bounds = _boundsForRoute(route.path);
    final startPoint = points.isNotEmpty ? points.first : null;
    final endPoint = points.length > 1 ? points.last : startPoint;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        title: Text(
          title,
          style: const TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: _primaryColor),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _centerForBounds(bounds),
                    initialZoom: 14,
                    initialCameraFit: CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(48),
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.lab2_moviles',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          strokeWidth: 5,
                          color: _primaryColor,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        if (startPoint != null)
                          Marker(
                            point: startPoint,
                            width: 52,
                            height: 52,
                            child: const _RoutePointMarker(
                              icon: Icons.play_arrow_rounded,
                              color: _primaryColor,
                            ),
                          ),
                        if (endPoint != null)
                          Marker(
                            point: endPoint,
                            width: 52,
                            height: 52,
                            child: const _RoutePointMarker(
                              icon: Icons.flag_rounded,
                              color: _accentColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricTile(
                    label: 'Distancia',
                    value: route.formattedDistance,
                  ),
                  _MetricTile(
                    label: 'Tiempo',
                    value: route.formattedDuration,
                  ),
                  _MetricTile(
                    label: 'Desnivel',
                    value: route.formattedElevationGain,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LatLngBounds _boundsForRoute(List<GeoNode> path) {
    if (path.isEmpty) {
      return LatLngBounds(
        const LatLng(9.9281, -84.0907),
        const LatLng(9.9281, -84.0907),
      );
    }

    var minLat = path.first.latitude;
    var maxLat = path.first.latitude;
    var minLon = path.first.longitude;
    var maxLon = path.first.longitude;

    for (final node in path.skip(1)) {
      if (node.latitude < minLat) minLat = node.latitude;
      if (node.latitude > maxLat) maxLat = node.latitude;
      if (node.longitude < minLon) minLon = node.longitude;
      if (node.longitude > maxLon) maxLon = node.longitude;
    }

    return LatLngBounds(
      LatLng(minLat, minLon),
      LatLng(maxLat, maxLon),
    );
  }

  LatLng _centerForBounds(LatLngBounds bounds) {
    return LatLng(
      (bounds.north + bounds.south) / 2,
      (bounds.east + bounds.west) / 2,
    );
  }
}

class _RoutePointMarker extends StatelessWidget {
  const _RoutePointMarker({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.24),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF012D1D),
          ),
        ),
      ],
    );
  }
}
