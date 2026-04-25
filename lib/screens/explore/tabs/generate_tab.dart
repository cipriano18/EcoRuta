import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

enum _RoutePreference { masCorta, masRapida, masDesafiante }

class GenerateTab extends StatefulWidget {
  const GenerateTab({super.key});

  @override
  State<GenerateTab> createState() => _GenerateTabState();
}

class _GenerateTabState extends State<GenerateTab> {
  static const _primaryColor = Color(0xFF012D1D);
  static const _primaryFixed = Color(0xFFC1ECD4);
  static const _orangeColor = Color(0xFFFF7043);
  static const _surfaceHigh = Color(0xFFE7E8E9);
  static const _surfaceHighest = Color(0xFFE1E3E4);
  static const _surfaceLow = Color(0xFFF3F4F5);
  static const _secondaryColor = Color(0xFF2C694E);
  static const _secondaryContainer = Color(0xFFAEEECB);
  static const _tertiaryContainer = Color(0xFF721D00);
  static const _tertiaryFixed = Color(0xFFFFB59F);

  final MapController _mapController = MapController();

  _RoutePreference _selectedPreference = _RoutePreference.masRapida;
  late List<_GeneratedRoute> _generatedRoutes;

  bool _isReversed = false;
  bool _hasGenerated = false;

  static const LatLng _startPoint = LatLng(9.9348, -84.0875);
  static const LatLng _destinationPoint = LatLng(10.0247, -84.1021);

  @override
  void initState() {
    super.initState();
    _generatedRoutes = _routesForPreference(_selectedPreference);
    _hasGenerated = true;
  }

  void _swapLocations() {
    setState(() => _isReversed = !_isReversed);
  }

  void _generateRoutes() {
    setState(() {
      _generatedRoutes = _routesForPreference(_selectedPreference);
      _hasGenerated = true;
    });
  }

  List<_GeneratedRoute> _routesForPreference(_RoutePreference preference) {
    switch (preference) {
      case _RoutePreference.masCorta:
        return const [
          _GeneratedRoute(
            title: 'Ruta de los Manantiales',
            distance: '5.4 km',
            duration: '1h 30m',
            elevationGain: '+110m',
            accentColor: _secondaryContainer,
            icon: Icons.water_drop_rounded,
          ),
          _GeneratedRoute(
            title: 'Sendero Verde',
            distance: '6.1 km',
            duration: '1h 48m',
            elevationGain: '+150m',
            accentColor: _primaryFixed,
            icon: Icons.park_rounded,
          ),
          _GeneratedRoute(
            title: 'Anillo Boscoso',
            distance: '7.2 km',
            duration: '2h 05m',
            elevationGain: '+185m',
            accentColor: _surfaceHighest,
            icon: Icons.forest_rounded,
          ),
        ];
      case _RoutePreference.masRapida:
        return const [
          _GeneratedRoute(
            title: 'Senda del Bosque',
            distance: '8.2 km',
            duration: '2h 15m',
            elevationGain: '+240m',
            accentColor: _primaryFixed,
            icon: Icons.route_rounded,
          ),
          _GeneratedRoute(
            title: 'Cima Volcánica',
            distance: '14.5 km',
            duration: '4h 45m',
            elevationGain: '+850m',
            badge: 'VISTA ÉPICA',
            accentColor: _tertiaryFixed,
            icon: Icons.local_fire_department_rounded,
            isHighlighted: true,
          ),
          _GeneratedRoute(
            title: 'Ruta del Mirador',
            distance: '9.1 km',
            duration: '2h 40m',
            elevationGain: '+280m',
            accentColor: _secondaryContainer,
            icon: Icons.landscape_rounded,
          ),
        ];
      case _RoutePreference.masDesafiante:
        return const [
          _GeneratedRoute(
            title: 'Cresta del Explorador',
            distance: '16.8 km',
            duration: '5h 20m',
            elevationGain: '+910m',
            badge: 'ALTA EXIGENCIA',
            accentColor: _tertiaryFixed,
            icon: Icons.terrain_rounded,
            isHighlighted: true,
          ),
          _GeneratedRoute(
            title: 'Ascenso del Guardabosque',
            distance: '13.2 km',
            duration: '4h 10m',
            elevationGain: '+760m',
            accentColor: _surfaceHighest,
            icon: Icons.hiking_rounded,
          ),
          _GeneratedRoute(
            title: 'Travesía Niebla Alta',
            distance: '11.7 km',
            duration: '3h 55m',
            elevationGain: '+640m',
            accentColor: _primaryFixed,
            icon: Icons.filter_hdr_rounded,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final startLabel = _isReversed ? 'Volcán Poás, CR' : 'San José, CR';
    final destinationLabel = _isReversed
        ? 'San José, CR'
        : 'Volcán Poás, CR';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        _MapHeroCard(
          mapController: _mapController,
          startPoint: _isReversed ? _destinationPoint : _startPoint,
          destinationPoint: _isReversed ? _startPoint : _destinationPoint,
          startLabel: startLabel,
          destinationLabel: destinationLabel,
          onSwap: _swapLocations,
        ),
        const SizedBox(height: 28),
        const _SectionTitle(title: 'Preferencia de Ruta'),
        const SizedBox(height: 14),
        _RoutePreferenceCard(
          title: 'Más Corta',
          subtitle: '12.4 km total',
          description:
              'Prioriza la distancia mínima sobre el terreno o elevación.',
          icon: Icons.straighten_rounded,
          accentColor: _primaryColor,
          backgroundColor: _surfaceLow,
          selected: _selectedPreference == _RoutePreference.masCorta,
          onTap: () {
            setState(() => _selectedPreference = _RoutePreference.masCorta);
          },
        ),
        const SizedBox(height: 12),
        _RoutePreferenceCard(
          title: 'Más Rápida',
          subtitle: '3h 15m est.',
          description:
              'Optimiza para senderos de alto flujo y menor dificultad técnica.',
          icon: Icons.bolt_rounded,
          accentColor: _primaryColor,
          backgroundColor: _primaryFixed,
          badgeText: 'Recomendado',
          selected: _selectedPreference == _RoutePreference.masRapida,
          onTap: () {
            setState(() => _selectedPreference = _RoutePreference.masRapida);
          },
        ),
        const SizedBox(height: 12),
        _RoutePreferenceCard(
          title: 'Más Desafiante',
          subtitle: 'Desnivel +800m',
          description:
              'Busca los picos más altos y las pendientes más técnicas del área.',
          icon: Icons.terrain_rounded,
          accentColor: _tertiaryContainer,
          backgroundColor: _tertiaryFixed,
          selected: _selectedPreference == _RoutePreference.masDesafiante,
          onTap: () {
            setState(
              () => _selectedPreference = _RoutePreference.masDesafiante,
            );
          },
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _generateRoutes,
          style: FilledButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            shadowColor: _primaryColor.withOpacity(0.22),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bolt_rounded, size: 24),
              SizedBox(width: 10),
              Text(
                'Generar Ruta',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _SectionTitle(title: 'Rutas Generadas'),
        const SizedBox(height: 4),
        Text(
          _hasGenerated
              ? 'Basado en tus preferencias actuales'
              : 'Aún no se han generado sugerencias',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ..._generatedRoutes.map(
          (route) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _GeneratedRouteCard(route: route),
          ),
        ),
      ],
    );
  }
}

class _MapHeroCard extends StatelessWidget {
  const _MapHeroCard({
    required this.mapController,
    required this.startPoint,
    required this.destinationPoint,
    required this.startLabel,
    required this.destinationLabel,
    required this.onSwap,
  });

  static const _primaryColor = Color(0xFF012D1D);
  static const _primaryFixed = Color(0xFFC1ECD4);
  static const _surfaceColor = Color(0xFFF8F9FA);
  static const _surfaceLow = Color(0xFFF3F4F5);
  static const _surfaceHighest = Color(0xFFE1E3E4);
  static const _tertiaryColor = Color(0xFF721D00);
  static const _tertiaryFixed = Color(0xFFFFB59F);

  final MapController mapController;
  final LatLng startPoint;
  final LatLng destinationPoint;
  final String startLabel;
  final String destinationLabel;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(
      (startPoint.latitude + destinationPoint.latitude) / 2,
      (startPoint.longitude + destinationPoint.longitude) / 2,
    );

    return SizedBox(
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
                        userAgentPackageName: 'com.example.lab2_moviles',
                      ),
                      Container(
                        color: _primaryColor.withOpacity(0.08),
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [startPoint, destinationPoint],
                            color: _primaryColor,
                            strokeWidth: 4,
                            pattern: StrokePattern.dashed(
                              segments: [8, 8],
                            ),
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: startPoint,
                            width: 84,
                            height: 52,
                            alignment: Alignment.topCenter,
                            child: const _StartMarker(),
                          ),
                          Marker(
                            point: destinationPoint,
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            child: const _DestinationMarker(),
                          ),
                        ],
                      ),
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
          Positioned(
            left: 18,
            right: 18,
            bottom: -30,
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _LocationRow(
                              label: 'Inicio',
                              value: startLabel,
                              icon: Icons.circle,
                              iconColor: _secondaryColor(startLabel),
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
                          decoration: const BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.swap_vert_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: _primaryColor,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'TrailAI Suggest',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _surfaceLow.withOpacity(0.9),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _surfaceHighest),
              ),
              child: const Text(
                'Ruta optimizada',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _tertiaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _secondaryColor(String _) => _primaryFixed;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: Color(0xFF012D1D),
        letterSpacing: -0.6,
      ),
    );
  }
}

class _RoutePreferenceCard extends StatelessWidget {
  const _RoutePreferenceCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.selected,
    required this.onTap,
    this.badgeText,
  });

  static const _primaryColor = Color(0xFF012D1D);

  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final bool selected;
  final VoidCallback onTap;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: selected ? _primaryColor : Colors.grey.shade200,
              width: selected ? 2 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(selected ? 0.08 : 0.04),
                blurRadius: selected ? 20 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (badgeText != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: const BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(26),
                        bottomLeft: Radius.circular(18),
                      ),
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  badgeText != null ? 18 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: selected ? accentColor : backgroundColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            icon,
                            color: selected ? Colors.white : accentColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: _primaryColor,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? _primaryColor
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.grey.shade100,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeneratedRouteCard extends StatelessWidget {
  const _GeneratedRouteCard({required this.route});

  static const _primaryColor = Color(0xFF012D1D);
  static const _secondaryContainer = Color(0xFFAEEECB);
  static const _surfaceLowest = Colors.white;

  final _GeneratedRoute route;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceLowest,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (route.badge != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: route.isHighlighted
                      ? const Color(0xFFFF825C)
                      : _primaryColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(28),
                    bottomLeft: Radius.circular(22),
                  ),
                ),
                child: Text(
                  route.badge!,
                  style: TextStyle(
                    color: route.isHighlighted
                        ? const Color(0xFF4C1000)
                        : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            route.accentColor,
                            route.accentColor.withOpacity(0.55),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 12,
                            top: 12,
                            child: Icon(
                              Icons.map_rounded,
                              size: 20,
                              color: _primaryColor,
                            ),
                          ),
                          Center(
                            child: Icon(
                              route.icon,
                              size: 34,
                              color: _primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _primaryColor,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 14,
                              runSpacing: 8,
                              children: [
                                _MetricChip(
                                  icon: Icons.straighten_rounded,
                                  value: route.distance,
                                  valueColor: Colors.grey.shade700,
                                ),
                                _MetricChip(
                                  icon: Icons.schedule_rounded,
                                  value: route.duration,
                                  valueColor: Colors.grey.shade700,
                                ),
                                _MetricChip(
                                  icon: Icons.trending_up_rounded,
                                  value: route.elevationGain,
                                  iconColor: const Color(0xFF721D00),
                                  valueColor: const Color(0xFF721D00),
                                  emphasized: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: _secondaryContainer,
                      foregroundColor: _primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Seleccionar',
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
        ],
      ),
    );
  }
}

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
              BoxShadow(
                color: _primaryColor.withOpacity(0.25),
                blurRadius: 10,
              ),
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
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
              ),
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

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  static const _tertiaryColor = Color(0xFF721D00);
  static const _tertiaryFixed = Color(0xFFFFB59F);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: _tertiaryFixed,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: _tertiaryColor.withOpacity(0.22),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Icon(
        Icons.location_on_rounded,
        size: 16,
        color: _tertiaryColor,
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.value,
    required this.valueColor,
    this.iconColor = Colors.grey,
    this.emphasized = false,
  });

  final IconData icon;
  final String value;
  final Color iconColor;
  final Color valueColor;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _GeneratedRoute {
  const _GeneratedRoute({
    required this.title,
    required this.distance,
    required this.duration,
    required this.elevationGain,
    required this.accentColor,
    required this.icon,
    this.badge,
    this.isHighlighted = false,
  });

  final String title;
  final String distance;
  final String duration;
  final String elevationGain;
  final Color accentColor;
  final IconData icon;
  final String? badge;
  final bool isHighlighted;
}
