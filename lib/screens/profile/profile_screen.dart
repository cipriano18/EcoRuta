import 'package:ecoruta/providers/user_provider.dart';
import 'package:ecoruta/routes/app_routes.dart';
import 'package:ecoruta/screens/profile/avatar_picker_screen.dart';
import 'package:ecoruta/screens/profile/change_password_screen.dart';
import 'package:ecoruta/screens/profile/delete_account_screen.dart';
import 'package:ecoruta/screens/profile/edit_account_screen.dart';
import 'package:ecoruta/screens/profile/user_rank_screen.dart';
import 'package:ecoruta/services/auth_service.dart';
import 'package:ecoruta/widgets/avatar_image.dart';
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

  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> _openAvatarPicker(int avatarId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AvatarPickerScreen(initialAvatarId: avatarId),
      ),
    );
  }

  Future<void> loadProfile() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
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
    final favoriteActivity = user?.favoriteActivity?.trim().isNotEmpty == true
        ? user!.favoriteActivity!
        : 'Ninguna';
    final completedRoutes = user?.completedRoutes ?? 0;
    final totalKilometers = user?.kmCounter ?? 0;
    final streakWeeks = user?.streakWeeks ?? 0;
    final currentRank = getUserRank(totalKilometers);
    final avatarId = user?.avatarId ?? 0;
    final safeAvatarId = avatarId >= 0 && avatarId < AvatarImage.avatarCount
        ? avatarId
        : 0;

    if (isLoadingProfile) {
      return const Scaffold(
        backgroundColor: surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
          children: [
            _profileHeader(
              fullName: fullName,
              avatarId: safeAvatarId,
              currentRankTitle: currentRank.title,
              totalKilometers: totalKilometers,
              streakWeeks: streakWeeks,
            ),
            const SizedBox(height: 36),
            _statsGrid(
              favoriteActivity: favoriteActivity,
              completedRoutes: completedRoutes,
              totalKilometers: totalKilometers,
            ),
            const SizedBox(height: 34),
            _settingsButton(),
            const SizedBox(height: 14),
            _changePasswordButton(),
            const SizedBox(height: 14),
            _deleteAccountButton(),
            const SizedBox(height: 14),
            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader({
    required String fullName,
    required int avatarId,
    required String currentRankTitle,
    required num totalKilometers,
    required int streakWeeks,
  }) {
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
                child: AvatarImage(
                  avatarId: avatarId,
                  size: 128,
                  backgroundColor: surfaceContainer,
                ),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: GestureDetector(
                onTap: () => _openAvatarPicker(avatarId),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          fullName,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: primary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserRankScreen(kmCounter: totalKilometers),
                  ),
                );
              },
              child: _profileBadge(
                icon: Icons.military_tech_rounded,
                label: currentRankTitle,
              ),
            ),
            _profileBadge(
              icon: Icons.local_fire_department_rounded,
              label: streakWeeks == 1 ? '1 semana' : '$streakWeeks semanas',
              iconColor: _streakPalette(streakWeeks).iconColor,
              textColor: _streakPalette(streakWeeks).textColor,
              backgroundColor: _streakPalette(streakWeeks).backgroundColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _profileBadge({
    required IconData icon,
    required String label,
    Color iconColor = secondary,
    Color textColor = secondary,
    Color backgroundColor = surfaceLow,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsGrid({
    required String favoriteActivity,
    required int completedRoutes,
    required num totalKilometers,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: primaryContainer,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL KILOMETROS',
                    style: TextStyle(
                      color: Color(0xFF86AF99),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatKmCounter(totalKilometers),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Padding(
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
              const DecoratedBox(
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
                value: completedRoutes.toString(),
                label: 'Rutas completadas',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _smallStatCard(
                icon: Icons.favorite,
                value: favoriteActivity,
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
      height: 146,
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
                  fontSize: smallerValue ? 18 : 38,
                  fontWeight: FontWeight.w900,
                  color: primary,
                  height: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatKmCounter(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  _StreakPalette _streakPalette(int streakWeeks) {
    if (streakWeeks > 50) {
      return const _StreakPalette(
        backgroundColor: Color(0xFFD7F5F2),
        iconColor: Color(0xFF0F8A83),
        textColor: Color(0xFF0B6F69),
      );
    }
    if (streakWeeks > 20) {
      return const _StreakPalette(
        backgroundColor: Color(0xFFFFE2D1),
        iconColor: Color(0xFFCC5A17),
        textColor: Color(0xFF9D3D00),
      );
    }
    if (streakWeeks > 0) {
      return const _StreakPalette(
        backgroundColor: Color(0xFFFFF2C7),
        iconColor: Color(0xFFC28A00),
        textColor: Color(0xFF8C6500),
      );
    }
    return const _StreakPalette(
      backgroundColor: surfaceLow,
      iconColor: Colors.grey,
      textColor: Colors.grey,
    );
  }

  Widget _settingsButton() {
    return _profileActionTile(
      icon: Icons.settings,
      title: 'Ajustes de Cuenta',
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const EditAccountScreen()));
      },
    );
  }

  Widget _changePasswordButton() {
    return _profileActionTile(
      icon: Icons.lock_reset_rounded,
      title: 'Cambiar contraseña',
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
      },
    );
  }

  Widget _logoutButton(BuildContext context) {
    return _profileActionTile(
      icon: Icons.logout_rounded,
      title: 'Cerrar sesion',
      iconColor: error,
      titleColor: error,
      onTap: () async {
        await AuthService().logout();

        if (!context.mounted) return;

        Provider.of<UserProvider>(context, listen: false).clear();
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      },
    );
  }

  Widget _deleteAccountButton() {
    return _profileActionTile(
      icon: Icons.delete_outline_rounded,
      title: 'Eliminar cuenta',
      iconColor: error,
      titleColor: error,
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const DeleteAccountScreen()));
      },
    );
  }

  Widget _profileActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = primary,
    Color titleColor = primary,
  }) {
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
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w900, color: titleColor),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _StreakPalette {
  const _StreakPalette({
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });

  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
}
