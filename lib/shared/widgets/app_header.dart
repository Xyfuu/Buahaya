import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/notification_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../core/extensions/context_x.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../domain/models/profile.dart';
import '../../core/constants/app_assets.dart';
import 'brand_mark.dart';
import 'user_avatar.dart';

/// Header tetap untuk tab utama: logo + judul halaman, lonceng, avatar.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.subtitle, required this.onBell, required this.onAvatar});

  static const double contentHeight = 64;

  final String subtitle;
  final VoidCallback onBell;
  final VoidCallback onAvatar;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final text = context.textTheme;
    final hasUnread = context.select<NotificationController, bool>((c) => c.hasUnread);
    final profile = context.select<ProfileController, UserProfile?>((c) => c.profile);

    return DecoratedBox(
      decoration: const BoxDecoration(boxShadow: AppShadows.header),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: contentHeight + top,
            padding: EdgeInsets.fromLTRB(16, top, 8, 0),
            color: const Color(0xD9ECFEF1),
            child: Material(
              type: MaterialType.transparency,
              child: Row(
                children: [
                  const BrandMark(size: 36, shadow: false, showCircles: false, imagePath: AppAssets.headerLogo),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Buahaya',
                          style: text.titleMedium!.copyWith(
                              color: AppColors.primary, letterSpacing: -0.45, height: 1.1)),
                      Text(subtitle,
                          style: text.labelSmall!.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const Spacer(),
                  Tooltip(
                    message: 'Notifications',
                    child: InkResponse(
                      onTap: onBell,
                      radius: 24,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.notifications_none_rounded, size: 24, color: AppColors.onSurface),
                            if (hasUnread)
                              Positioned(
                                top: 10,
                                right: 11,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.background, width: 1.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Profile',
                    child: InkResponse(
                      onTap: onAvatar,
                      radius: 24,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(child: UserAvatar(profile: profile, size: 34)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
