import 'package:ecoruta/widgets/route_result_card.dart';
import 'package:ecoruta/widgets/scr_explore/suggestion_item.dart';
import 'package:flutter/material.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  static const _primaryColor = Color(0xFF012D1D);
  static const _primaryFixed = Color(0xFFC1ECD4);
  static const _orangeColor = Color(0xFFFF7043);
  static const _surfaceHighest = Color(0xFFE1E3E4);

  int _selectedActivity = 0; // 0 = ciclismo, 1 = senderismo
  double _radius = 25;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        // ── Destino ────────────────────────────────────────────────
        _SectionLabel(text: 'Destino'),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: '¿A dónde quieres ir?',
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
            filled: true,
            fillColor: _surfaceHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
        const SizedBox(height: 8),
        // Sugerencias
        SuggestionItem(
          title: 'Volcán Poás',
          subtitle: 'Alajuela, Costa Rica',
          onTap: () {},
        ),
        SuggestionItem(
          title: 'Reserva Monteverde',
          subtitle: 'Puntarenas, Costa Rica',
          onTap: () {},
        ),
        SuggestionItem(
          title: 'Reserva Monteverde',
          subtitle: 'Puntarenas, Costa Rica',
          onTap: () {},
        ),
        SuggestionItem(
          title: 'Reserva Monteverde',
          subtitle: 'Puntarenas, Costa Rica',
          onTap: () {},
        ),
        const SizedBox(height: 28),

        // ── Tipo de actividad ──────────────────────────────────────
        _SectionLabel(text: 'Tipo de Actividad'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActivityCard(
                icon: Icons.directions_bike_rounded,
                label: 'Ciclismo',
                selected: _selectedActivity == 0,
                onTap: () => setState(() => _selectedActivity = 0),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ActivityCard(
                icon: Icons.hiking_rounded,
                label: 'Senderismo',
                selected: _selectedActivity == 1,
                onTap: () => setState(() => _selectedActivity = 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ── Radio de búsqueda ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryFixed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.explore_rounded,
                          size: 14,
                          color: _primaryColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Rango Óptimo',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

        // ── Ruta destacada ─────────────────────────────────────────
        _SectionLabel(text: 'Ruta Destacada'),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
        RouteResultCard(
          title: 'PH Reventazon',
          subtitle: 'Represa turistica y senderos.',
          difficulty: 'EXPERT',
          distance: '9.2',
          duration: '4.5',
          altitude: '1420',
          onTap: () {},
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────
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

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const _primaryColor = Color(0xFF012D1D);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _primaryColor : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF2C694E),
              size: 28,
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : const Color(0xFF191C1D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
