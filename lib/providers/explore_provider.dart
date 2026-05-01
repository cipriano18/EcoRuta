import 'dart:math' as math;

import 'package:ecoruta/models/geo_edge.dart';
import 'package:ecoruta/models/geo_node.dart';
import 'package:ecoruta/models/route_profile.dart';
import 'package:ecoruta/services/elevation/elevation_service.dart';
import 'package:ecoruta/services/overpass/osm_mapper.dart';
import 'package:ecoruta/services/overpass/overpass_service.dart';
import 'package:ecoruta/services/routing/a_star_router.dart';
import 'package:ecoruta/services/routing/route_result.dart';
import 'package:flutter/foundation.dart';

class ExploreProvider extends ChangeNotifier {
  ExploreProvider({
    OverpassService? overpassService,
    OsmMapper? osmMapper,
    AStarRouter? router,
    ElevationService? elevationService,
  }) : _overpassService = overpassService ?? OverpassService(),
       _osmMapper = osmMapper ?? const OsmMapper(),
       _router = router ?? const AStarRouter(),
       _elevationService = elevationService ?? ElevationService();

  final OverpassService _overpassService;
  final OsmMapper _osmMapper;
  final AStarRouter _router;
  final ElevationService _elevationService;

  RouteProfile _selectedProfile = RouteProfile.hiking;
  bool _isLoading = false;
  String? _errorMessage;
  List<GeoNode> _nodes = const [];
  List<GeoEdge> _edges = const [];
  List<Map<String, dynamic>> _rawWays = const [];
  Map<String, dynamic>? _lastPayload;
  Map<RoutingPreference, RouteResult?> _routes = const {};

  RouteProfile get selectedProfile => _selectedProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<GeoNode> get nodes => _nodes;
  List<GeoEdge> get edges => _edges;
  List<Map<String, dynamic>> get rawWays => _rawWays;
  Map<String, dynamic>? get lastPayload => _lastPayload;
  Map<RoutingPreference, RouteResult?> get routes => _routes;

  void setProfile(RouteProfile profile) {
    if (_selectedProfile == profile) return;
    _selectedProfile = profile;
    notifyListeners();
  }

  // Descarga el grafo OSM para el área entre los dos puntos, ejecuta A*
  // con las tres preferencias y enriquece los paths con elevación SRTM.
  Future<void> generateRoutes({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _routes = const {};

    try {
      const pad = 0.05;
      final south = math.min(startLat, endLat) - pad;
      final north = math.max(startLat, endLat) + pad;
      final west = math.min(startLon, endLon) - pad;
      final east = math.max(startLon, endLon) + pad;

      final payload = await _overpassService.fetchRoutesInBoundingBox(
        south: south,
        west: west,
        north: north,
        east: east,
        profile: _selectedProfile,
      );
      _applyPayload(payload, _selectedProfile);

      final startNode = _router.nearestNode(_nodes, _edges, startLat, startLon);
      final endNode = _router.nearestNode(_nodes, _edges, endLat, endLon);

      if (startNode == null || endNode == null) {
        _errorMessage = 'No se encontraron nodos en el área seleccionada.';
        return;
      }

      // Calcular A* para las 3 preferencias.
      final rawResults = <RoutingPreference, RouteResult?>{};
      for (final pref in RoutingPreference.values) {
        rawResults[pref] = _router.findRoute(
          nodes: _nodes,
          edges: _edges,
          startId: startNode.id,
          goalId: endNode.id,
          preference: pref,
        );
      }

      if (rawResults.values.every((r) => r == null)) {
        _errorMessage = 'No se pudo calcular ninguna ruta entre los puntos.';
        return;
      }

      // Recolectar nodos únicos de los 3 paths para hacer UNA sola
      // llamada a la API de elevación en lugar de tres.
      final uniqueNodes = <int, GeoNode>{};
      for (final result in rawResults.values) {
        if (result != null) {
          for (final node in result.path) {
            uniqueNodes[node.id] = node;
          }
        }
      }

      final enrichedList = await _elevationService.enrichWithElevation(
        uniqueNodes.values.toList(),
      );
      final enrichedMap = {for (final n in enrichedList) n.id: n};

      // Aplicar elevación a cada resultado.
      final results = <RoutingPreference, RouteResult?>{};
      for (final entry in rawResults.entries) {
        final result = entry.value;
        if (result == null) {
          results[entry.key] = null;
          continue;
        }
        final enrichedPath =
            result.path.map((n) => enrichedMap[n.id] ?? n).toList();
        results[entry.key] = result.withElevation(enrichedPath);
      }

      _routes = results;
    } on OverpassException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Error al generar rutas: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRoutesInBoundingBox({
    required double south,
    required double west,
    required double north,
    required double east,
    RouteProfile? profile,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final effectiveProfile = profile ?? _selectedProfile;
      final payload = await _overpassService.fetchRoutesInBoundingBox(
        south: south,
        west: west,
        north: north,
        east: east,
        profile: effectiveProfile,
      );

      _selectedProfile = effectiveProfile;
      _applyPayload(payload, effectiveProfile);
    } on OverpassException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'No se pudieron cargar rutas desde Overpass: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadRoutesAroundPoint({
    required double latitude,
    required double longitude,
    required int radiusMeters,
    RouteProfile? profile,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final effectiveProfile = profile ?? _selectedProfile;
      final payload = await _overpassService.fetchRoutesAroundPoint(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        profile: effectiveProfile,
      );

      _selectedProfile = effectiveProfile;
      _applyPayload(payload, effectiveProfile);
    } on OverpassException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'No se pudieron cargar rutas desde Overpass: $error';
    } finally {
      _setLoading(false);
    }
  }

  void clearData() {
    _errorMessage = null;
    _nodes = const [];
    _edges = const [];
    _rawWays = const [];
    _lastPayload = null;
    _routes = const {};
    notifyListeners();
  }

  void _applyPayload(Map<String, dynamic> payload, RouteProfile profile) {
    final graph = _osmMapper.mapToGraph(payload, profile: profile);
    _lastPayload = payload;
    _nodes = graph.nodes;
    _edges = graph.edges;
    _rawWays = graph.rawWays;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
