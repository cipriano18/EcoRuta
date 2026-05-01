import 'package:ecoruta/providers/user_provider.dart';
import 'package:ecoruta/services/auth_service.dart';
import 'package:ecoruta/widgets/avatar_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvatarPickerScreen extends StatefulWidget {
  const AvatarPickerScreen({super.key, required this.initialAvatarId});

  final int initialAvatarId;

  @override
  State<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends State<AvatarPickerScreen> {
  static const _primary = Color(0xFF012D1D);
  static const _surface = Color(0xFFF8F9FA);

  late int _selectedAvatarId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedAvatarId = widget.initialAvatarId;
  }

  Future<void> _saveAvatar() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final user = provider.user;

    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await AuthService().updateAvatar(_selectedAvatarId);
      provider.setUser(user.copyWith(avatarId: _selectedAvatarId));

      if (!mounted) return;
      Navigator.of(context).pop(_selectedAvatarId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el avatar')),
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
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _primary,
        title: const Text(
          'Cambiar avatar',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Elige tu nuevo icono',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona uno de los avatares disponibles para actualizar tu perfil.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  itemCount: AvatarImage.avatarCount,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedAvatarId == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatarId = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFCFEFDC)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? _primary
                                : const Color(0xFFE2E5E7),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: AvatarImage(
                                avatarId: index,
                                size: 72,
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            if (isSelected)
                              const Positioned(
                                top: 0,
                                right: 0,
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: _primary,
                                  size: 22,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAvatar,
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
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Guardar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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
}
