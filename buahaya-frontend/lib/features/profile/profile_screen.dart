import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/profile_controller.dart';
import '../../core/config/app_config.dart';
import '../../controllers/shopping_controller.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/profile.dart';
import '../../domain/models/shopping.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../shared/widgets/app_image.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_popups.dart';
import '../../shared/widgets/surface_card.dart';
import '../../shared/widgets/user_avatar.dart';
import '../lists/widgets/haul_preview_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final profile = context.watch<ProfileController>().profile;
    final shopping = context.watch<ShoppingController>();

    if (profile == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<ProfileController>().load(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _IdentityCard(profile: profile, listCount: profile.shoppingListCount, checks: profile.freshCheckCount, partners: profile.partnerCount),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.photo_library_outlined, size: 20, color: AppColors.onSurface),
              const SizedBox(width: 8),
              Expanded(child: Text('Your fruit hauls', style: text.titleMedium)),
              TextButton(
                onPressed: () => context.go('${AppRoutes.lists}?tab=history'),
                child: Text('View all (${shopping.history.length})',
                    style: text.labelMedium!.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (shopping.history.isEmpty)
            SurfaceCard(child: Text('Finish a shopping trip to see your fruit hauls here.', style: text.bodyLarge))
          else
            SizedBox(
              height: 196,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: shopping.history.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _HaulThumb(trip: shopping.history[i]),
              ),
            ),
          const SizedBox(height: 20),
          const _SettingsCard(),
          const SizedBox(height: 16),
          AppButton(
            label: 'Log out',
            kind: AppButtonKind.dangerSoft,
            icon: Icons.logout_rounded,
            onPressed: () async {
              final ok = await showPopup<bool>(
                context,
                builder: (ctx) => ConfirmPopup(
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.danger,
                  iconBackground: AppColors.dangerSoft,
                  title: 'Log Out?',
                  message: 'Are you sure you want to log out? You will need to sign in again to access your shopping lists and sync data.',
                  actions: [
                    AppButton(label: 'Yes', kind: AppButtonKind.danger, onPressed: () => Navigator.of(ctx).pop(true)),
                    AppButton(label: 'Cancel', kind: AppButtonKind.neutral, onPressed: () => Navigator.of(ctx).pop(false)),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await context.read<AuthController>().logout();
              }
            },
          ),
          const SizedBox(height: 16),
          Center(child: Text('Buahaya ${AppConfig.version}', style: text.labelSmall!.copyWith(color: AppColors.outline))),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile, required this.listCount, required this.checks, required this.partners});

  final UserProfile profile;
  final int listCount;
  final int checks;
  final int partners;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  UserAvatar(profile: profile, size: 72),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: () => context.push(AppRoutes.editProfile),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.photo_camera_outlined, size: 14, color: AppColors.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.fullName, style: text.titleMedium),
                    Text(profile.email, style: text.bodyMedium),
                  ],
                ),
              ),
              InkResponse(
                radius: 22,
                onTap: () => context.push(AppRoutes.editProfile),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Stat(value: '$listCount', label: 'Shopping list'),
              _Stat(value: '$checks', label: 'AI fresh checks'),
              _Stat(value: '$partners', label: 'List partners'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: text.titleMedium!.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
            Text(label, style: text.labelSmall!.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _HaulThumb extends StatelessWidget {
  const _HaulThumb({required this.trip});
  final ShoppingTrip trip;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return SizedBox(
      width: 220,
      child: SurfaceCard(
        padding: const EdgeInsets.all(8),
        onTap: () => showHaulPreviewSheet(context, trip),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AppImage(
                    source: AppAssets.haulBackground,
                    width: 204,
                    height: 124,
                    fallback: Container(
                      width: 204,
                      height: 124,
                      alignment: Alignment.center,
                      color: AppColors.surfaceContainer,
                      child: Text(
                        trip.fruits.isEmpty ? '🧺' : trip.fruits.first.fruit.emoji,
                        style: const TextStyle(fontSize: 52),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xCC000000), borderRadius: BorderRadius.circular(999)),
                    child: Text('${trip.fruitTypes} fruit types',
                        style: text.labelSmall!.copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(trip.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: text.labelLarge!.copyWith(letterSpacing: 0)),
            Text(formatDate(trip.finishedAt), style: text.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final profile = context.watch<ProfileController>();
    final on = profile.profile?.notificationsEnabled ?? true;

    Widget row(IconData icon, String title, String sub, Widget trailing, VoidCallback? onTap) => InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, size: 19, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.labelLarge!.copyWith(letterSpacing: 0)),
                      Text(sub, style: text.bodyMedium),
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        );

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings & account', style: text.titleSmall),
          const SizedBox(height: 4),
          row(Icons.notifications_none_rounded, 'Notification Alert', 'Turn on to notify me',
              Switch(value: on, onChanged: (v) => profile.setNotifications(v)), null),
          row(Icons.help_outline_rounded, 'Help & Privacy Policy', 'FAQs, scan guide & data license',
              const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
              () => context.push(AppRoutes.help)),
        ],
      ),
    );
  }
}
