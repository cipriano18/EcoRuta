import 'package:ecoruta/models/geo_edge.dart';
import 'package:ecoruta/models/geo_node.dart';
import 'package:ecoruta/models/route_profile.dart';
import 'package:ecoruta/services/overpass/osm_mapper.dart';
import 'package:ecoruta/services/overpass/overpass_service.dart';
import 'package:flutter/foundation.dart';

class ExploreProvider extends ChangeNotifier {
  ExploreProvider({
    OverpassService? overpassService,
    OsmMapper? osmMapper,
  }) : _overpassService = overpassService ?? OverpassService(),
       _osmMapper = osmMapper ?? const OsmMapper();

  final OverpassService _overpassService;
  final OsmMapper _osmMapper;

  RouteProfile _selectedProfile = RouteProfile.hiking;
  bool _isLoading = false;
  String? _errorMessage;
  List<GeoNode> _nodes = const [];
  List<GeoEdge> _edges = const [];
  List<Map<String, dynamic>> _rawWays = const [];
  Map<String, dynamic>? _lastPayload;

  RouteProfile get selectedProfile => _selectedProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<GeoNode> get nodes => _nodes;
  List<GeoEdge> get edges => _edges;
  List<Map<String, dynamic>> get rawWays => _rawWays;
  Map<String, dynamic>? get lastPayload => _lastPayload;

  void setProfile(RouteProfile profile) {
    if (_selectedProfile == profile) {
      return;
    }

    _selectedProfile = profile;
    notifyListeners();
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
