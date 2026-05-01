import 'package:ecoruta/screens/picker_map.dart';
import 'package:ecoruta/widgets/activity_type_card.dart';
import 'package:ecoruta/widgets/points_preview.dart';
import 'package:ecoruta/widgets/preference_card.dart';
import 'package:ecoruta/widgets/route_result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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
  static const _surfaceHighest = Color(0xFFE1E3E4);
  static const _surfaceLow = Color(0xFFF3F4F5);
  static const _secondaryContainer = Color(0xFFAEEECB);
  static const _tertiaryContainer = Color(0xFF721D00);
  static const _tertiaryFixed = Color(0xFFFFB59F);

  final MapController _mapController = MapController();
  _RoutePreference _selectedPreference = _RoutePreference.masRapida;
  late List<_GeneratedRoute> _generatedRoutes;

  LatLng? _startPoint;
  LatLng? _destinationPoint;
  LatLng? _currentLocation;
  int _selectedActivity = 1;
  String _startLabel = 'Cargando ubicación actual...';
  String _destinationLabel = 'Pendiente de seleccionar';
  bool _isLoadingCurrentLocation = true;
  bool _hasGenerated = false;

  @override
  void initState() {
    super.initState();
    _generatedRoutes = _routesForPreference(_selectedPreference);
    _hasGenerated = true;
    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _isLoadingCurrentLocation = false;
          _startLabel = 'Ubicación actual no disponible';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final currentPoint = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() {
        _currentLocation = currentPoint;
        _startPoint = currentPoint;
        _startLabel = _formatCoordinates(currentPoint);
        _isLoadingCurrentLocation = false;
      });
      _syncPreviewMap();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingCurrentLocation = false;
        _startLabel = 'Ubicación actual no disponible';
      });
    }
  }

  void _swapLocations() {
    setState(() {
      final previousStartPoint = _startPoint;
      final previousStartLabel = _startLabel;
      _startPoint = _destinationPoint;
      _startLabel = _destinationLabel;
      _destinationPoint = previousStartPoint;
      _destinationLabel = previousStartLabel;
    });
    _syncPreviewMap();
  }

  Future<void> _openPointsPicker() async {
    final result = await Navigator.of(context).push<PointsSelectionResult>(
      MaterialPageRoute(
        builder: (_) => PickerMapScreen(
          initialStartPoint: _startPoint,
          initialDestinationPoint: _destinationPoint,
          currentLocation: _currentLocation,
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _startPoint = result.startPoint;
      _destinationPoint = result.destinationPoint;
      _startLabel = result.startLabel;
      _destinationLabel = result.destinationLabel;
    });
    _syncPreviewMap();
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
    final previewStartLabel = _isLoadingCurrentLocation
        ? 'Cargando ubicación actual...'
        : _startLabel;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        PointsPreview(
          mapController: _mapController,
          startPoint: _startPoint,
          destinationPoint: _destinationPoint,
          startLabel: previewStartLabel,
          destinationLabel: _destinationLabel,
          onSwap: _swapLocations,
          onSelectPoints: _openPointsPicker,
        ),
        const SizedBox(height: 28),
        const _SectionTitle(title: 'Preferencia de Ruta'),
        const SizedBox(height: 14),
        PreferenceCard(
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
        PreferenceCard(
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
        PreferenceCard(
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
        const _SectionTitle(title: 'Tipo de actividad'),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ActivityTypeCard(
                icon: Icons.directions_bike_rounded,
                label: 'Ciclismo',
                selected: _selectedActivity == 0,
                onTap: () => setState(() => _selectedActivity = 0),
              ),
              const SizedBox(width: 14),
              ActivityTypeCard(
                icon: Icons.hiking_rounded,
                label: 'Senderismo',
                selected: _selectedActivity == 1,
                onTap: () => setState(() => _selectedActivity = 1),
              ),
              const SizedBox(width: 14),
              ActivityTypeCard(
                icon: Icons.directions_run_rounded,
                label: 'Running',
                selected: _selectedActivity == 2,
                onTap: () => setState(() => _selectedActivity = 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const _ScrollHint(),
        const SizedBox(height: 20),
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
            child: RouteResultCard(
              title: route.title,
              distance: route.distance,
              duration: route.duration,
              elevationGain: route.elevationGain,
              accentColor: route.accentColor,
              icon: route.icon,
              badge: route.badge,
              isHighlighted: route.isHighlighted,
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  String _formatCoordinates(LatLng point) {
    return '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
  }

  void _syncPreviewMap() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final center = _startPoint != null && _destinationPoint != null
          ? LatLng(
              (_startPoint!.latitude + _destinationPoint!.latitude) / 2,
              (_startPoint!.longitude + _destinationPoint!.longitude) / 2,
            )
          : _startPoint ?? _destinationPoint;

      if (center != null) {
        _mapController.move(center, 11.5);
      }
    });
  }
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

class _ScrollHint extends StatelessWidget {
  const _ScrollHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: const [
        Text(
          'Desliza para ver más',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 6),
        Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
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
