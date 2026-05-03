import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Previsualiza en pequeño el origen y destino seleccionados.
class PointsPreview extends StatelessWidget {
  static const _primaryColor = Color(0xFF012D1D);
  static const _primaryFixed = Color(0xFFC1ECD4);
  static const _surfaceColor = Color(0xFFF8F9FA);
  static const _swapButtonColor = Color(0xFF2C694E);
  static const _tertiaryFixed = Color(0xFFFFB59F);
  static const _fallbackCenter = LatLng(9.9281, -84.0907);

  final MapController mapController;
  final LatLng? startPoint;
  final LatLng? destinationPoint;
  final String startLabel;
  final String destinationLabel;
  final VoidCallback onSwap;
  final VoidCallback onSelectPoints;

  const PointsPreview({
    super.key,
    required this.mapController,
    required this.startPoint,
    required this.destinationPoint,
    required this.startLabel,
    required this.destinationLabel,
    required this.onSwap,
    required this.onSelectPoints,
  });

  @override
  Widget build(BuildContext context) {
    final center = _resolveCenter();
    final markers = <Marker>[
      if (startPoint != null)
        Marker(
          point: startPoint!,
          width: 84,
          height: 52,
          alignment: Alignment.topCenter,
          child: const _StartMarker(),
        ),
      if (destinationPoint != null)
        Marker(
          point: destinationPoint!,
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: const _DestinationMarker(),
        ),
    ];

    return SizedBox(
      height: 432,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 320,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: SizedBox.expand(
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              initialCenter: center,
                              initialZoom: 11.5,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.lab2_moviles',
                              ),
                              Container(color: _primaryColor.withOpacity(0.08)),
                              MarkerLayer(markers: markers),
                            ],
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: IgnorePointer(
                              child: Container(
                                height: 120,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color.fromRGBO(248, 249, 250, 0),
                                      _surfaceColor,
                                    ],
                                    stops: [0, 0.92],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            top: 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _LocationRow(
                                  label: 'Inicio',
                                  value: startLabel,
                                  icon: Icons.circle,
                                  iconColor: _primaryFixed,
                                ),
                                const SizedBox(height: 14),
                                _LocationRow(
                                  label: 'Destino',
                                  value: destinationLabel,
                                  icon: Icons.location_on_rounded,
                                  iconColor: _tertiaryFixed,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: onSwap,
                            borderRadius: BorderRadius.circular(24),
                            child: Ink(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: _swapButtonColor),
                              ),
                              child: const Icon(
                                Icons.swap_vert_rounded,
                                color: _swapButtonColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onSelectPoints,
                          style: FilledButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            'Seleccionar puntos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LatLng _resolveCenter() {
    if (startPoint != null && destinationPoint != null) {
      return LatLng(
        (startPoint!.latitude + destinationPoint!.latitude) / 2,
        (startPoint!.longitude + destinationPoint!.longitude) / 2,
      );
    }
    return startPoint ?? destinationPoint ?? _fallbackCenter;
  }
}

/// Fila de texto para mostrar una ubicación seleccionada.
class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: label == 'Destino'
                      ? FontWeight.w600
                      : FontWeight.w800,
                  color: const Color(0xFF191C1D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Marcador visual del punto de inicio en la miniatura del mapa.
class _StartMarker extends StatelessWidget {
  const _StartMarker();

  static const _primaryColor = Color(0xFF012D1D);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _primaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: _primaryColor.withOpacity(0.25), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10),
            ],
          ),
          child: const Text(
            'Inicio',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Marcador visual del punto de destino en la miniatura del mapa.
class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  static const _tertiaryColor = Color(0xFF721D00);
  static const _tertiaryFixed = Color(0xFFFFB59F);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: _tertiaryFixed,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: _tertiaryColor.withOpacity(0.22), blurRadius: 10),
        ],
      ),
      child: const Icon(Icons.flag_rounded, size: 12, color: _tertiaryColor),
    );
  }
}

/*
widget encargado de mostrar la vista previa de los puntos seleccionados
en la pantalla picker_map.dart
*/
