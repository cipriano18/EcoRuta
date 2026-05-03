import 'package:ecoruta/models/stored_route.dart';
import 'package:ecoruta/models/route_profile.dart';
import 'package:flutter/material.dart';

/// Tarjeta visual para listar rutas guardadas con acciones rápidas.
class MyRouteCard extends StatelessWidget {
  const MyRouteCard({
    super.key,
    required this.route,
    required this.onOpen,
    required this.onDelete,
    required this.onToggleVisibility,
  });

  static const primaryColor = Color(0xFF012D1D);
  static const accentGreen = Color(0xFFAEEECB);

  final StoredRoute route;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: accentGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _iconForProfile(route),
                size: 40,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _PillLabel(text: route.activityLabel),
                                _PillLabel(text: route.visibilityLabel),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: onToggleVisibility,
                            icon: Icon(
                              route.isPublic
                                  ? Icons.public
                                  : Icons.lock_outline,
                              size: 20,
                            ),
                            tooltip: route.isPublic
                                ? 'Cambiar a privada'
                                : 'Cambiar a publica',
                          ),
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline, size: 20),
                            tooltip: 'Eliminar ruta',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${route.startLabel} -> ${route.endLabel}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RouteMetric(
                        label: 'Distancia',
                        value: _formatDistance(route.totalDistanceMeters),
                      ),
                      _RouteMetric(
                        label: 'Elevacion',
                        value: '+${route.elevationGainMeters.round()} m',
                      ),
                      _RouteMetric(
                        label: 'Tiempo',
                        value: _formatDuration(route.estimatedDurationSeconds),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForProfile(StoredRoute route) {
    switch (route.activityProfile) {
      case RouteProfile.cycling:
        return Icons.directions_bike;
      case RouteProfile.hiking:
        return Icons.hiking;
      case RouteProfile.running:
        return Icons.directions_run;
    }
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes}m';
  }
}

/// Etiqueta compacta para actividad o visibilidad de la ruta.
class _PillLabel extends StatelessWidget {
  const _PillLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: MyRouteCard.primaryColor,
        ),
      ),
    );
  }
}

/// Muestra una métrica resumida dentro de la tarjeta de ruta.
class _RouteMetric extends StatelessWidget {
  const _RouteMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.black45,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: MyRouteCard.primaryColor,
          ),
        ),
      ],
    );
  }
}
