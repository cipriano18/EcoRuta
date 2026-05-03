import 'package:ecoruta/models/route_profile.dart';
import 'package:ecoruta/screens/explore/route_preview_screen.dart';
import 'package:ecoruta/providers/explore_provider.dart';
import 'package:ecoruta/screens/picker_map.dart';
import 'package:ecoruta/services/routing/a_star_router.dart';
import 'package:ecoruta/services/routing/route_result.dart';
import 'package:ecoruta/widgets/activity_type_card.dart';
import 'package:ecoruta/widgets/points_preview.dart';
import 'package:ecoruta/widgets/preference_card.dart';
import 'package:ecoruta/widgets/route_result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class GenerateTab extends StatefulWidget {
  const GenerateTab({super.key});

  @override
  State<GenerateTab> createState() => _GenerateTabState();
}

class _GenerateTabState extends State<GenerateTab> {
  static const _primaryColor = Color(0xFF012D1D);
  static const _primaryFixed = Color(0xFFC1ECD4);
  static const _surfaceLow = Color(0xFFF3F4F5);
  static const _secondaryContainer = Color(0xFFAEEECB);
  static const _tertiaryContainer = Color(0xFF721D00);
  static const _tertiaryFixed = Color(0xFFFFB59F);

  final MapController _mapController = MapController();

  static const _selectedPreference = RoutingPreference.masCorta;
  RouteProfile _selectedProfile = RouteProfile.hiking;
  LatLng? _startPoint;
  LatLng? _destinationPoint;
  LatLng? _currentLocation;
  String _startLabel = 'Cargando ubicacion actual...';
  String _destinationLabel = 'Pendiente de seleccionar';
  bool _isLoadingCurrentLocation = true;
  bool _hasGenerated = false;

  @override
  void initState() {
    super.initState();
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
          _startLabel = 'Ubicacion actual no disponible';
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
        _startLabel = 'Ubicacion actual no disponible';
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

  Future<void> _generateRoutes() async {
    if (_startPoint == null || _destinationPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un punto de inicio y un destino.'),
        ),
      );
      return;
    }

    final straightLineDistanceKm = _straightLineDistanceKm(
      _startPoint!,
      _destinationPoint!,
    );
    final maxDistanceKm = _selectedProfile.maxRecommendedDistanceKm;

    if (straightLineDistanceKm > maxDistanceKm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _distanceLimitMessage(
              profile: _selectedProfile,
              maxDistanceKm: maxDistanceKm,
            ),
          ),
        ),
      );
      return;
    }

    final provider = context.read<ExploreProvider>();
    provider.setProfile(_selectedProfile);

    setState(() => _hasGenerated = true);

    await provider.generateRoutes(
      startLat: _startPoint!.latitude,
      startLon: _startPoint!.longitude,
      endLat: _destinationPoint!.latitude,
      endLon: _destinationPoint!.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final previewStartLabel = _isLoadingCurrentLocation
        ? 'Cargando ubicacion actual...'
        : _startLabel;

    return Consumer<ExploreProvider>(
      builder: (context, exploreProvider, _) {
        final selectedRoute = exploreProvider.routes[_selectedPreference];

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
              title: 'Mas Corta',
              subtitle: 'Minimiza la distancia total',
              description:
                  'Prioriza el recorrido de menor distancia entre los puntos seleccionados.',
              icon: Icons.straighten_rounded,
              accentColor: _primaryColor,
              backgroundColor: _surfaceLow,
              selected: true,
              badgeText: 'ACTIVA',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            PreferenceCard(
              title: 'Mas Rapida',
              subtitle: 'Minimiza el tiempo estimado',
              description:
                  'La dejaremos fuera del flujo principal mientras estabilizamos el grafo base por actividad.',
              icon: Icons.bolt_rounded,
              accentColor: _primaryColor,
              backgroundColor: _primaryFixed,
              badgeText: 'PROXIMAMENTE',
              selected: false,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            PreferenceCard(
              title: 'Mas Desafiante',
              subtitle: 'Favorece el desnivel positivo',
              description:
                  'Volvera despues de validar que la ruta mas corta use un grafo amplio y conectado.',
              icon: Icons.terrain_rounded,
              accentColor: _tertiaryContainer,
              backgroundColor: _tertiaryFixed,
              badgeText: 'PROXIMAMENTE',
              selected: false,
              onTap: () {},
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
                    selected: _selectedProfile == RouteProfile.cycling,
                    onTap: () {
                      setState(() => _selectedProfile = RouteProfile.cycling);
                    },
                  ),
                  const SizedBox(width: 14),
                  ActivityTypeCard(
                    icon: Icons.hiking_rounded,
                    label: 'Senderismo',
                    selected: _selectedProfile == RouteProfile.hiking,
                    onTap: () {
                      setState(() => _selectedProfile = RouteProfile.hiking);
                    },
                  ),
                  const SizedBox(width: 14),
                  ActivityTypeCard(
                    icon: Icons.directions_run_rounded,
                    label: 'Running',
                    selected: _selectedProfile == RouteProfile.running,
                    onTap: () {
                      setState(() => _selectedProfile = RouteProfile.running);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const _ScrollHint(),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: exploreProvider.isLoading ? null : _generateRoutes,
              style: FilledButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                shadowColor: _primaryColor.withValues(alpha: 0.22),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (exploreProvider.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(Icons.bolt_rounded, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    exploreProvider.isLoading
                        ? 'Generando rutas...'
                        : 'Generar Ruta',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const _SectionTitle(title: 'Rutas Generadas'),
            const SizedBox(height: 4),
            Text(
              _resultSummaryText(exploreProvider, selectedRoute),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),
            if (exploreProvider.errorMessage != null && _hasGenerated)
              _InfoCard(
                message: exploreProvider.errorMessage!,
                icon: Icons.error_outline_rounded,
                iconColor: Colors.redAccent,
              )
            else if (!_hasGenerated)
              const _InfoCard(
                message:
                    'Selecciona la actividad, el origen y el destino para calcular la ruta mas corta.',
                icon: Icons.route_rounded,
                iconColor: _primaryColor,
              )
            else if (exploreProvider.isLoading)
              const _InfoCard(
                message: 'Calculando la ruta mas corta...',
                icon: Icons.sync_rounded,
                iconColor: _primaryColor,
              )
            else if (selectedRoute == null)
              const _InfoCard(
                message:
                    'No se encontro una ruta para esta preferencia con los puntos seleccionados.',
                icon: Icons.alt_route_rounded,
                iconColor: _primaryColor,
              )
            else
              RouteResultCard(
                title: _titleForRoute(_selectedProfile, _selectedPreference),
                distance: selectedRoute.formattedDistance,
                duration: selectedRoute.formattedDuration,
                elevationGain: selectedRoute.formattedElevationGain,
                accentColor: _accentForPreference(_selectedPreference),
                icon: _iconForPreference(_selectedPreference),
                badge: _badgeForRoute(selectedRoute),
                isHighlighted: false,
                buttonText: 'Ver trazado',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RoutePreviewScreen(
                        title: _titleForRoute(
                          _selectedProfile,
                          _selectedPreference,
                        ),
                        route: selectedRoute,
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  String _resultSummaryText(
    ExploreProvider provider,
    RouteResult? selectedRoute,
  ) {
    if (!_hasGenerated) {
      return 'Aun no se han generado sugerencias';
    }
    if (provider.isLoading) {
      return 'Calculando ruta mas corta para ${_activityLabel(_selectedProfile).toLowerCase()}';
    }
    if (provider.errorMessage != null) {
      return 'No se pudo generar la ruta mas corta con los puntos elegidos';
    }
    if (selectedRoute == null) {
      return 'No hubo resultado para la ruta mas corta';
    }
    return 'Resultado real de la ruta mas corta para ${_activityLabel(_selectedProfile).toLowerCase()}';
  }

  String _activityLabel(RouteProfile profile) {
    switch (profile) {
      case RouteProfile.cycling:
        return 'Ciclismo';
      case RouteProfile.hiking:
        return 'Senderismo';
      case RouteProfile.running:
        return 'Running';
    }
  }

  String _titleForRoute(
    RouteProfile profile,
    RoutingPreference preference,
  ) {
    final activity = _activityLabel(profile);
    switch (preference) {
      case RoutingPreference.masCorta:
        return '$activity - Ruta mas corta';
      case RoutingPreference.masRapida:
        return '$activity - Ruta mas rapida';
      case RoutingPreference.masDesafiante:
        return '$activity - Ruta mas desafiante';
    }
  }

  String? _badgeForRoute(RouteResult route) {
    if (route.totalDistanceMeters > 0) {
      return 'MAS CORTA';
    }
    return null;
  }

  Color _accentForPreference(RoutingPreference preference) {
    switch (preference) {
      case RoutingPreference.masCorta:
        return _secondaryContainer;
      case RoutingPreference.masRapida:
        return _primaryFixed;
      case RoutingPreference.masDesafiante:
        return _tertiaryFixed;
    }
  }

  IconData _iconForPreference(RoutingPreference preference) {
    switch (preference) {
      case RoutingPreference.masCorta:
        return Icons.straighten_rounded;
      case RoutingPreference.masRapida:
        return Icons.bolt_rounded;
      case RoutingPreference.masDesafiante:
        return Icons.terrain_rounded;
    }
  }

  String _formatCoordinates(LatLng point) {
    return '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
  }

  double _straightLineDistanceKm(LatLng start, LatLng end) {
    final distanceMeters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
    return distanceMeters / 1000;
  }

  String _distanceLimitMessage({
    required RouteProfile profile,
    required double maxDistanceKm,
  }) {
    final activity = _activityLabel(profile).toLowerCase();
    return 'Para $activity, el origen y destino no deben superar ${maxDistanceKm.toStringAsFixed(0)} km en linea recta.';
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
          'Desliza para ver mas',
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.message,
    required this.icon,
    required this.iconColor,
  });

  final String message;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF191C1D),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
