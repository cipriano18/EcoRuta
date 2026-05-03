import 'package:flutter/material.dart';

class SuggestionItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SuggestionItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const _primaryColor = Color(0xFF012D1D);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: _primaryColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF191C1D),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/*
widget para mustrar las sugerencias de ubicaciones
segun lo que escriba el usuario en los imputs de busqueda

Actualmente se usa en:
picker_map.dart
search_tab.dart
*/