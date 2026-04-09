import 'package:flutter/material.dart';

class ActiveRouteCard extends StatefulWidget {
  final String routeName;
  final String distance;
  final String duration;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;

  const ActiveRouteCard({
    super.key,
    required this.routeName,
    required this.distance,
    required this.duration,
    this.onPause,
    this.onResume,
    this.onCancel,
  });

  @override
  State<ActiveRouteCard> createState() => _ActiveRouteCardState();
}

class _ActiveRouteCardState extends State<ActiveRouteCard> {
  static const _primaryColor = Color(0xFF012D1D);
  bool _isPaused = false;

  void _togglePauseResume() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      widget.onPause?.call();
    } else {
      widget.onResume?.call();
    }
  }

  void _cancelRoute() {
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isPaused ? Colors.orange : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isPaused ? 'SESIÓN EN PAUSA' : 'SESIÓN EN VIVO',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _isPaused ? Colors.orange : Colors.green,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.routeName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _primaryColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ActiveRouteMetric(
                icon: Icons.straighten_rounded,
                value: widget.distance,
                unit: 'km',
              ),
              const SizedBox(width: 16),
              Container(width: 1, height: 36, color: Colors.grey.shade200),
              const SizedBox(width: 16),
              ActiveRouteMetric(
                icon: Icons.schedule_rounded,
                value: widget.duration,
                unit: 'm',
              ),
              const Spacer(),

              if (_isPaused) ...[
                GestureDetector(
                  onTap: _cancelRoute,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.red.shade700,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],

              GestureDetector(
                onTap: _togglePauseResume,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActiveRouteMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;

  const ActiveRouteMetric({
    super.key,
    required this.icon,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green.shade700, size: 18),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Color(0xFF191C1D)),
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: unit,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
