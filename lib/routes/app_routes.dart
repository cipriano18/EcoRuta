import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../providers/explore_provider.dart';
import '../navigation/main_shell.dart';
import '../screens/explore/overpass_test_screen.dart';

class AppRoutes {
  // Rutas de autenticación (sin nav bar)
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String overpassTest = '/overpass-test';

  // App principal (con nav bar)
  static const String shell = '/shell';

  static Map<String, WidgetBuilder> get routes => {
    home: (_) => const HomeScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    shell: (_) => const MainShell(),
    overpassTest: (_) => ChangeNotifierProvider(
      create: (_) => ExploreProvider(),
      child: const OverpassTestScreen(),
    ),
  };
}
