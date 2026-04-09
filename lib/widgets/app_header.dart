import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  static const _primaryColor = Color(0xFF012D1D);
  static const _primaryFixed = Color(0xFFC1ECD4);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.92),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: _primaryColor),
        onPressed: () {},
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.eco_rounded, color: _primaryFixed, size: 22),
          SizedBox(width: 6),
          Text(
            'EcoRuta',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _primaryColor,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: _primaryColor.withOpacity(0.1),
            child: const Icon(
              Icons.person_rounded,
              color: _primaryColor,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
