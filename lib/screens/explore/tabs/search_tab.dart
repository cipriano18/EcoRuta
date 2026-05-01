import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ecoruta/widgets/activity_type_card.dart';
import 'package:ecoruta/widgets/route_result_card.dart';
import 'package:ecoruta/widgets/suggestion_item.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  static const _primaryColor = Color(0xFF012D1D);
  static const _surfaceHighest = Color(0xFFE1E3E4);
  static const _nominatimUserAgent = 'EcoRutaCR/1.0';

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  List<_PlaceSuggestion> _suggestions = [];
  LatLng? _currentLocation;
  bool _isSearching = false;

  int _selectedActivity = 0;
  double _radius = 25;

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (_) {
      // Si falla, seguimos sin ubicación actual.
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        _SectionLabel(text: 'Destino'),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          onSubmitted: (_) => _searchSuggestions(_searchController.text),
          decoration: InputDecoration(
            hintText: '¿A dónde quieres ir?',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            filled: true,
            fillColor: _surfaceHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          ..._suggestions
              .take(4)
              .map(
                (suggestion) => SuggestionItem(
                  title: suggestion.title,
                  subtitle: suggestion.subtitle,
                  onTap: () => _selectSuggestion(suggestion),
                ),
              ),
        ],
        const SizedBox(height: 28),

        _SectionLabel(text: 'Tipo de Actividad'),
        const SizedBox(height: 12),
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
        const _HorizontalScrollHint(),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(text: 'Radio de Búsqueda'),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${_radius.toInt()} ',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: _primaryColor,
                        letterSpacing: -1,
                      ),
                    ),
                    const TextSpan(
                      text: 'km',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _primaryColor,
                  inactiveTrackColor: _surfaceHighest,
                  thumbColor: _primaryColor,
                  overlayColor: _primaryColor.withOpacity(0.1),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _radius,
                  min: 1,
                  max: 100,
                  onChanged: (v) => setState(() => _radius = v),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    '1 KM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '100 KM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        _SectionLabel(text: 'Ruta Destacada'),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
        RouteResultCard(
          title: 'PH Reventazon',
          distance: '9.2 km',
          duration: '4h 30m',
          elevationGain: '+1420m',
          accentColor: const Color(0xFFFFB59F),
          icon: Icons.terrain_rounded,
          badge: 'EXPERT',
          isHighlighted: true,
          onPressed: () {},
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () {
      _searchSuggestions(value);
    });
  }

  Future<void> _searchSuggestions(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': trimmed,
        'format': 'jsonv2',
        'limit': '8',
        'addressdetails': '1',
      });
      final responseBody = await _getJson(uri);
      final List<dynamic> data = jsonDecode(responseBody) as List<dynamic>;

      final suggestions = data
          .map(
            (item) => _PlaceSuggestion.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      suggestions.sort((a, b) {
        final importanceCompare = b.importance.compareTo(a.importance);
        if (importanceCompare != 0) return importanceCompare;
        if (_currentLocation == null) return 0;
        final distanceA = const Distance().as(
          LengthUnit.Meter,
          _currentLocation!,
          a.point,
        );
        final distanceB = const Distance().as(
          LengthUnit.Meter,
          _currentLocation!,
          b.point,
        );
        return distanceA.compareTo(distanceB);
      });

      if (!mounted) return;
      setState(() {
        _suggestions = suggestions.take(4).toList();
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
    }
  }

  Future<String> _getJson(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.userAgentHeader, _nominatimUserAgent);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Request failed', uri: uri);
      }
      return responseBody;
    } finally {
      client.close();
    }
  }

  void _selectSuggestion(_PlaceSuggestion suggestion) {
    _searchController.text = suggestion.title;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );
    _searchFocusNode.unfocus();
    setState(() {
      _suggestions = [];
    });
  }
}

class _PlaceSuggestion {
  const _PlaceSuggestion({
    required this.title,
    required this.subtitle,
    required this.point,
    required this.importance,
  });

  final String title;
  final String subtitle;
  final LatLng point;
  final double importance;

  factory _PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final displayName = (json['display_name'] as String? ?? '').trim();
    final parts = displayName.split(',');

    return _PlaceSuggestion(
      title: parts.isNotEmpty && parts.first.trim().isNotEmpty
          ? parts.first.trim()
          : 'Lugar encontrado',
      subtitle: parts.length > 1
          ? parts.skip(1).take(2).map((part) => part.trim()).join(', ')
          : 'Sin detalles',
      point: LatLng(
        double.parse(json['lat'] as String),
        double.parse(json['lon'] as String),
      ),
      importance: (json['importance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Color(0xFFFFB59F),
        letterSpacing: 2,
      ),
    );
  }
}

class _HorizontalScrollHint extends StatelessWidget {
  const _HorizontalScrollHint();

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
