import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int selectedAvatar = 0;
  bool obscurePassword = true;

  final List<String> avatars = [
    '👨',
    '👩',
    '🧑',
    '👨‍🦱',
    '👩‍🦰',
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF012D1D);
    const orangeColor = Color(0xFFFF7043);
    const surfaceColor = Color(0xFFEDEEEF);
    const labelColor = Color(0xFFB8A39A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Crear Cuenta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ÚNETE A LA EXPEDICIÓN',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w800,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Comienza tu aventura',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Únete a la comunidad de exploradores de EcoRuta.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 28),

              _buildLabel('Nombre completo'),
              _buildTextField(
                hint: 'Tu nombre y apellido',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _buildLabel('Correo electrónico'),
              _buildTextField(
                hint: 'ejemplo@ecoruta.com',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),

              _buildLabel('Dirección'),
              _buildTextField(
                hint: 'Calle, Número, Ciudad',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),

              _buildLabel('Nombre de usuario'),
              _buildTextField(
                hint: '@usuario',
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 16),

              _buildLabel('Contraseña'),
              TextField(
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Mínimo 8 caracteres',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  filled: true,
                  fillColor: surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 28),
              const Text(
                'Selecciona tu avatar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 14),

              SizedBox(
                height: 82,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: avatars.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final isSelected = selectedAvatar == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAvatar = index;
                        });
                      },
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? const Color(0xFFC1ECD4)
                              : surfaceColor,
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            avatars[index],
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registro de ejemplo completado')),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text(
                    'Registrarse',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'o continúa con',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text(
                    'Google',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('¿Ya tienes una cuenta? Iniciar sesión'),
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                'Al registrarte, aceptas nuestros Términos de Servicio y Política de Privacidad. EcoRuta utiliza datos de ubicación para trazar tus rutas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: Color(0xFF012D1D),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFEDEEEF),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}