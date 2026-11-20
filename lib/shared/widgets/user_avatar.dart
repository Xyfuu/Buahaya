import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/profile.dart';
import 'app_image.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.profile, this.size = 32});

  final UserProfile? profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFC4F66B), Color(0xFF91D5B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text('🍐', style: TextStyle(fontSize: size * 0.55)),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: size > 60 ? 4 : 1.5),
      ),
      child: ClipOval(
        child: AppImage(
          source: profile?.avatarUrl,
          width: size,
          height: size,
          fallback: fallback,
        ),
      ),
    );
  }
}
