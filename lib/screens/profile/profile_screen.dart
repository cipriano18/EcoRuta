import 'package:ecoruta/providers/user_provider.dart';
import 'package:ecoruta/routes/app_routes.dart';
import 'package:ecoruta/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const primary = Color(0xFF012D1D);
  static const primaryContainer = Color(0xFF1B4332);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceLow = Color(0xFFF3F4F5);
  static const surfaceContainer = Color(0xFFEDEEEF);
  static const secondary = Color(0xFF2C694E);
  static const error = Color(0xFFBA1A1A);

  static const List<String> avatars = [
    '👨',
    '👩',
    '🧑',
    '👨‍🦱',
    '👩‍🦰',
  ];

  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final provider = Provider.of<UserProvider>(context, listen: false);

    if (provider.user != null) {
      setState(() {
        isLoadingProfile = false;
      });
      return;
    }

    final userProfile = await AuthService().getCurrentUserProfile();

    if (userProfile != null) {
      provider.setUser(userProfile);
    }

    if (mounted) {
      setState(() {
        isLoadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    final fullName = user?.fullName ?? 'Usuario';
    final avatarId = user?.avatarId ?? 0;
    final safeAvatarId = avatarId >= 0 && avatarId < avatars.length ? avatarId : 0;
    final avatar = avatars[safeAvatarId];

    if (isLoadingProfile) {
      return const Scaffold(
        backgroundColor: surface,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
          children: [
            _topBar(avatar),
            const SizedBox(height: 32),
            _profileHeader(fullName, avatar),
            const SizedBox(height: 36),
            _statsGrid(),
            const SizedBox(height: 34),
            _athleteLevel(),
            const SizedBox(height: 34),
            _settingsButton(),
            const SizedBox(height: 14),
            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _topBar(String avatar) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.menu, color: primary),
            SizedBox(width: 14),
            Text(
              'TrailAI',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: primary,
              ),
            ),
          ],
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: surfaceContainer,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              avatar,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileHeader(String fullName, String avatar) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: surfaceContainer,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  avatar,
                  style: const TextStyle(fontSize: 72),
                ),
              ),
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC1C8C2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, color: primary, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: primary,
          ),
        ),
      ],
    );
  }

  Widget _statsGrid() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: primaryContainer,
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL KILÓMETROS',
                    style: TextStyle(
                      color: Color(0xFF86AF99),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '1,284',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 6),
                      Padding(
                        padding: EdgeInsets.only(bottom: 7),
                        child: Text(
                          'KM',
                          style: TextStyle(
                            color: Color(0xFF86AF99),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.10),
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(Icons.timeline, color: Colors.white, size: 34),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _smallStatCard(
                icon: Icons.route,
                value: '42',
                label: 'Rutas completadas',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _smallStatCard(
                icon: Icons.favorite,
                value: 'Trail Running',
                label: 'Actividad favorita',
                smallerValue: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _smallStatCard({
    required IconData icon,
    required String value,
    required String label,
    bool smallerValue = false,
  }) {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: secondary, size: 26),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: smallerValue ? 20 : 38,
                  fontWeight: FontWeight.w900,
                  color: primary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.black54,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _athleteLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 14),
          child: Text(
            'Nivel de Atleta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: primary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              _levelButton('Principiante', false),
              _levelButton('Intermedio', true),
              _levelButton('Avanzado', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _levelButton(String text, bool selected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? primary : surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _settingsButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.settings, color: primary),
        ),
        title: const Text(
          'Ajustes de Cuenta',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: primary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await AuthService().logout();

        if (!context.mounted) return;

        Provider.of<UserProvider>(context, listen: false).clear();

        Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
      child: const Text(
        'Cerrar sesión',
        style: TextStyle(
          color: error,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}