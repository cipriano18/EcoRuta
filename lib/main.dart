import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const EcoRutaApp());
}

class EcoRutaApp extends StatelessWidget {
  const EcoRutaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoRuta',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF012D1D),
          brightness: Brightness.light,
        ),
        fontFamily: 'Arial',
      ),
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
    );
  }
}
