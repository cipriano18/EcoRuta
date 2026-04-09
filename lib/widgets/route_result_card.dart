import 'package:ecoruta/widgets/route_metric.dart';
import 'package:flutter/material.dart';

class RouteResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String difficulty;
  final String distance;
  final String duration;
  final String altitude;
  final double imageHeight;
  final VoidCallback? onTap;

  const RouteResultCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.distance,
    required this.altitude,
    required this.duration,
    this.imageHeight = 180,
    this.onTap,
  });

  static const _primaryColor = Color(0xFF012D1D);
  static const _orangeColor = Color(0xFFFF7043);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: imageHeight,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(
                      Icons.image_rounded,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _orangeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      difficulty.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _primaryColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: RouteMetric(
                          icon: Icons.straighten_rounded,
                          label: 'Distancia',
                          value: distance,
                          unit: 'km',
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFFE1E3E4),
                      ),

                      Expanded(
                        child: RouteMetric(
                          icon: Icons.schedule_rounded,
                          label: 'Tiempo',
                          value: duration,
                          unit: 'h',
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFFE1E3E4),
                      ),

                      Expanded(
                        child: RouteMetric(
                          icon: Icons.terrain_rounded,
                          label: 'Altitud',
                          value: altitude,
                          unit: 'm',
                        ),
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
}
