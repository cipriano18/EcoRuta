import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../navigation/main_shell.dart';

class AppRoutes {
  // Rutas de autenticación (sin nav bar)
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';

  // App principal (con nav bar)
  static const String shell = '/shell';

  static Map<String, WidgetBuilder> get routes => {
    home: (_) => const HomeScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    shell: (_) => const MainShell(),
  };
}
