import 'package:ecoruta/routes/app_routes.dart';
import 'package:ecoruta/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecoruta/models/user_model.dart';
import 'package:ecoruta/providers/user_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int selectedAvatar = 0;
  bool obscurePassword = true;
  bool isLoading = false;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final List<String> avatars = [
    '👨',
    '👩',
    '🧑',
    '👨‍🦱',
    '👩‍🦰',
  ];

  Future<void> registerUser() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        address.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener mínimo 6 caracteres'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userCredential = await AuthService().register(
        fullName: fullName,
        email: email,
        address: address,
        password: password,
        avatarId: selectedAvatar,
      );

      final uid = userCredential.user!.uid;

      final data = await AuthService().getUserData(uid);

      if (data != null) {
        final userModel = UserModel.fromMap(data);

        if (!mounted) return;

        Provider.of<UserProvider>(context, listen: false)
            .setUser(userModel);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado correctamente')),
      );

      Navigator.pushReplacementNamed(context, AppRoutes.shell);
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Error al registrar usuario';

      if (e.code == 'email-already-in-use') {
        mensaje = 'Ese correo ya está registrado';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El correo no tiene un formato válido';
      } else if (e.code == 'weak-password') {
        mensaje = 'La contraseña es muy débil';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    addressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
                ),
              ),
              const SizedBox(height: 28),

              _buildLabel('Nombre completo'),
              _buildTextField(
                controller: fullNameController,
                hint: 'Tu nombre y apellido',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _buildLabel('Correo electrónico'),
              _buildTextField(
                controller: emailController,
                hint: 'ejemplo@ecoruta.com',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),

              _buildLabel('Dirección'),
              _buildTextField(
                controller: addressController,
                hint: 'Heredia, Costa Rica',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 16),

              _buildLabel('Contraseña'),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Mínimo 6 caracteres',
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text('Selecciona tu avatar'),
              const SizedBox(height: 10),

              Row(
                children: List.generate(avatars.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAvatar = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedAvatar == index
                            ? Colors.green.shade100
                            : surfaceColor,
                      ),
                      child: Text(
                        avatars[index],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Registrarse'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text.toUpperCase());
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}