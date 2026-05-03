import 'package:ecoruta/providers/user_provider.dart';
import 'package:ecoruta/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Pantalla para editar los campos básicos del perfil del usuario.
class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  static const _primary = Color(0xFF012D1D);
  static const _surface = Color(0xFFEDEEEF);
  static const _favoriteActivities = ['Senderismo', 'Ciclismo', 'Running'];

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isSaving = false;
  String _selectedActivity = 'Senderismo';

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _fullNameController.text = user?.fullName ?? '';
    _emailController.text = user?.email ?? '';
    _addressController.text = user?.address ?? '';
    _selectedActivity = _favoriteActivities.contains(user?.favoriteActivity)
        ? user!.favoriteActivity!
        : 'Senderismo';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Guarda los cambios del perfil y sincroniza el estado local.
  Future<void> _saveProfile() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final user = provider.user;

    if (user == null) return;

    final fullName = _fullNameController.text.trim();
    final address = _addressController.text.trim();

    if (fullName.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos requeridos')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await AuthService().updateProfile(
        fullName: fullName,
        address: address,
        favoriteActivity: _selectedActivity,
      );

      provider.setUser(
        user.copyWith(
          fullName: fullName,
          address: address,
          favoriteActivity: _selectedActivity,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar la cuenta: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _primary,
        title: const Text(
          'Editar cuenta',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Actualiza tus datos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aqui puedes cambiar tu nombre, direccion y actividad favorita. El correo y el avatar se administran por separado.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 28),
              _buildLabel('Nombre completo'),
              _buildStyledField(
                controller: _fullNameController,
                hintText: 'Tu nombre y apellido',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildLabel('Correo electronico'),
              _buildDisabledField(),
              const SizedBox(height: 16),
              _buildLabel('Direccion'),
              _buildStyledField(
                controller: _addressController,
                hintText: 'Heredia, Costa Rica',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),
              _buildLabel('Actividad favorita'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _favoriteActivities.map((activity) {
                  final isSelected = _selectedActivity == activity;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedActivity = activity;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? _primary : _surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        activity,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                      : const Text(
                          'Guardar cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Presenta la etiqueta descriptiva de cada grupo del formulario.
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: Colors.black54,
        ),
      ),
    );
  }

  /// Construye campos editables con el estilo visual del módulo de perfil.
  Widget _buildStyledField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Muestra el correo como referencia sin permitir su edición directa.
  Widget _buildDisabledField() {
    return TextField(
      enabled: false,
      controller: _emailController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email_outlined),
        filled: true,
        fillColor: const Color(0xFFE6E8EA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
