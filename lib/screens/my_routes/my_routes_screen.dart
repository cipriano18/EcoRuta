import 'package:flutter/material.dart';

class MyRoutesScreen extends StatelessWidget {
  const MyRoutesScreen({super.key});

  static const primaryColor = Color(0xFF012D1D);
  static const surfaceColor = Color(0xFFF8F9FA);
  static const surfaceLow = Color(0xFFF3F4F5);
  static const accentGreen = Color(0xFFAEEECB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFilters(),
                const SizedBox(height: 20),
                _buildRouteCard(
                  title: "Senda del Quetzal",
                  location: "Monteverde, Puntarenas",
                  distance: "8.4 km",
                  elevation: "420 m",
                  time: "2h 15m",
                  icon: Icons.directions_run,
                ),
                _buildRouteCard(
                  title: "Circuito Volcán Arenal",
                  location: "La Fortuna, Alajuela",
                  distance: "22.1 km",
                  elevation: "680 m",
                  time: "1h 45m",
                  icon: Icons.directions_bike,
                ),
                _buildRouteCard(
                  title: "Costa del Pacífico",
                  location: "Manuel Antonio, Quepos",
                  distance: "5.2 km",
                  elevation: "120 m",
                  time: "1h 10m",
                  icon: Icons.hiking,
                ),
              ],
            ),

            /// 🔥 FAB estilo HTML
            Positioned(
              bottom: 20,
              right: 20,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.add_location_alt),
                label: const Text("Crear mi ruta"),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 🟢 HEADER
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "MI BIBLIOTECA",
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w800,
            color: Colors.orange,
          ),
        ),
        SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Mis rutas",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: primaryColor,
              ),
            ),
            Text(
              "12 Guardadas",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          "Revive tus aventuras favoritas o planifica tu próximo desafío.",
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  /// 🟢 FILTROS
  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip("Todas", selected: true),
          _filterChip("Senderismo"),
          _filterChip("Ciclismo"),
          _filterChip("Trail Running"),
        ],
      ),
    );
  }

  Widget _filterChip(String text, {bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
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
    );
  }

  /// 🟢 CARD DE RUTA
  Widget _buildRouteCard({
    required String title,
    required String location,
    required String distance,
    required String elevation,
    required String time,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          /// Imagen simulada
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: accentGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 40, color: primaryColor),
          ),
          const SizedBox(width: 14),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Título
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.share, size: 18),
                        SizedBox(width: 8),
                        Icon(Icons.delete, size: 18),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 4),

                /// Ubicación
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// Métricas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metric("Distancia", distance),
                    _metric("Elevación", elevation),
                    _metric("Tiempo", time),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.black45,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }
}