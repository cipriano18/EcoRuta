import 'package:flutter/material.dart';

class AvatarImage extends StatelessWidget {
  const AvatarImage({
    super.key,
    required this.avatarId,
    this.size = 48,
    this.backgroundColor = const Color(0xFFEDEEEF),
    this.iconColor = const Color(0xFF012D1D),
  });

  static const int avatarCount = 10;

  static String assetPathFor(int avatarId) {
    final normalizedId = avatarId.clamp(0, avatarCount - 1);
    final fileIndex = normalizedId + 1;
    return 'assets/images/avatars/icon$fileIndex.png';
  }

  final int avatarId;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: backgroundColor,
        child: Image.asset(
          assetPathFor(avatarId),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person_rounded,
              size: size * 0.52,
              color: iconColor,
            );
          },
        ),
      ),
    );
  }
}
