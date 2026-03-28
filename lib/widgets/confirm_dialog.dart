import 'package:flutter/material.dart';

/// Diálogo de confirmación reutilizable para acciones destructivas.
class ConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;

  const ConfirmDialog({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoConfirmar = 'Eliminar',
  });

  /// Muestra el diálogo y retorna [true] si el usuario confirma, [false] si cancela.
  static Future<bool> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    String textoConfirmar = 'Eliminar',
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        titulo: titulo,
        mensaje: mensaje,
        textoConfirmar: textoConfirmar,
      ),
    );
    return resultado ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(textoConfirmar),
        ),
      ],
    );
  }
}
