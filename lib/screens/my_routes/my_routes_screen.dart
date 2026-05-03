import 'package:ecoruta/models/saved_route_item.dart';
import 'package:ecoruta/widgets/app_header.dart';
import 'package:ecoruta/widgets/confirm_dialog.dart';
import 'package:ecoruta/widgets/my_route_card.dart';
import 'package:flutter/material.dart';

class MyRoutesScreen extends StatefulWidget {
  const MyRoutesScreen({super.key});

  @override
  State<MyRoutesScreen> createState() => _MyRoutesScreenState();
}

class _MyRoutesScreenState extends State<MyRoutesScreen> {
  static const primaryColor = Color(0xFF012D1D);
  static const surfaceColor = Color(0xFFF8F9FA);
  static const surfaceLow = Color(0xFFF3F4F5);
  static const _allFilter = 'Todas';
  static const List<String> _filters = [
    _allFilter,
    'Senderismo',
    'Ciclismo',
    'Running',
  ];

  late final List<SavedRouteItem> _savedRoutes = [
    const SavedRouteItem(
      id: 'quetzal',
      title: 'Senda del Quetzal',
      location: 'Monteverde, Puntarenas',
      distance: '8.4 km',
      elevation: '420 m',
      time: '2h 15m',
      icon: Icons.directions_run,
      activityType: 'Running',
    ),
    const SavedRouteItem(
      id: 'arenal',
      title: 'Circuito Volcan Arenal',
      location: 'La Fortuna, Alajuela',
      distance: '22.1 km',
      elevation: '680 m',
      time: '1h 45m',
      icon: Icons.directions_bike,
      activityType: 'Ciclismo',
    ),
    const SavedRouteItem(
      id: 'pacifico',
      title: 'Costa del Pacifico',
      location: 'Manuel Antonio, Quepos',
      distance: '5.2 km',
      elevation: '120 m',
      time: '1h 10m',
      icon: Icons.hiking,
      activityType: 'Senderismo',
    ),
  ];

  String _selectedFilter = _allFilter;

  List<SavedRouteItem> get _visibleRoutes {
    if (_selectedFilter == _allFilter) return _savedRoutes;
    return _savedRoutes
        .where((route) => route.activityType == _selectedFilter)
        .toList();
  }

  Future<void> _removeRoute(SavedRouteItem route) async {
    final confirmed = await ConfirmDialog.mostrar(
      context,
      titulo: 'Eliminar ruta',
      mensaje: 'Quieres eliminar "${route.title}" de tu lista guardada?',
      textoConfirmar: 'Eliminar',
    );

    if (!confirmed || !mounted) return;

    setState(() {
      _savedRoutes.removeWhere((item) => item.id == route.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleRoutes = _visibleRoutes;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: const AppHeader(backgroundColor: surfaceColor),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              children: [
                _buildHeader(savedRoutesCount: _savedRoutes.length),
                const SizedBox(height: 24),
                _buildFilters(),
                const SizedBox(height: 20),
                if (visibleRoutes.isEmpty)
                  _buildEmptyState()
                else
                  ...visibleRoutes.map(
                    (route) => MyRouteCard(
                      route: route,
                      onDelete: () => _removeRoute(route),
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Crear mi ruta'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({required int savedRoutesCount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MI BIBLIOTECA',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mis rutas',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: primaryColor,
              ),
            ),
            Text(
              '$savedRoutesCount Guardadas',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Revive tus aventuras favoritas o planifica tu proximo desafio.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters
                .map(
                  (filter) =>
                      _filterChip(filter, selected: _selectedFilter == filter),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        const Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String text, {bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = text;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? primaryColor : surfaceLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(Icons.map_outlined, size: 44, color: Color(0xFF012D1D)),
          SizedBox(height: 12),
          Text(
            'No hay rutas para este filtro',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Prueba con otra actividad o agrega nuevas rutas a tu biblioteca.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, height: 1.4),
          ),
        ],
      ),
    );
  }
}
