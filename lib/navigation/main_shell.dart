import 'package:flutter/material.dart';
import '../screens/map/map_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/my_routes/my_routes_screen.dart';
import '../screens/profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _primaryColor = Color(0xFF012D1D);

  // Las 4 pantallas del nav — el orden debe coincidir con los tabs
  final List<Widget> _screens = const [
    MapScreen(),
    ExploreScreen(),
    MyRoutesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cada tab muestra su pantalla sin rebuilds innecesarios
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Inicio',
                active: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
                activeColor: _primaryColor,
              ),
              _NavItem(
                icon: Icons.explore_rounded,
                label: 'Explorar',
                active: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
                activeColor: _primaryColor,
              ),
              _NavItem(
                icon: Icons.directions_run_rounded,
                label: 'Mis rutas',
                active: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
                activeColor: _primaryColor,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Perfil',
                active: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
                activeColor: _primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab item individual ───────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color activeColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: active ? activeColor : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: active ? activeColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
