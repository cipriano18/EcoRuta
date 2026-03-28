import 'package:flutter/material.dart';

/// Barra de búsqueda reutilizable.
/// Notifica al padre cada vez que el texto cambia mediante [onChanged].
class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String placeholder;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.placeholder = 'Buscar lugar...',
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _limpiar() {
    _controlador.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controlador,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.placeholder,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _controlador.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: _limpiar,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}
