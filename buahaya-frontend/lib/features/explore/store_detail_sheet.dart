import 'package:flutter/material.dart';

import '../../shared/widgets/app_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/store_controller.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/utils/external_launcher.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/store.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_popups.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../core/theme/app_colors.dart';

class StoreImage extends StatelessWidget {
  const StoreImage({super.key, required this.store, this.size = 80});

  final FruitStore store;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AppImage(
        source: store.imageUrl,
        width: size,
        height: size,
        fallback: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFDDB8), Color(0xFFACF2CB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Text('🧺', style: TextStyle(fontSize: size * 0.45)),
        ),
      ),
    );
  }
}

class OpenBadge extends StatelessWidget {
  const OpenBadge({super.key, required this.open});
  final bool open;

  @override
  Widget build(BuildContext context) => PillBadge(
        label: open ? 'Open' : 'Closed',
        backgroundColor: open ? AppColors.surfaceContainerHigh : AppColors.errorContainer,
        foregroundColor: open ? AppColors.primary : AppColors.onErrorContainer,
      );
}

Future<void> showStoreDetailSheet(BuildContext context, FruitStore store) {
  final stores = context.read<StoreController>();
  return showAppSheet<void>(
    context,
    builder: (ctx) {
      final text = ctx.textTheme;
      final open = store.isOpenAt(DateTime.now());
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StoreImage(store: store, size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.name, style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text('${formatDistance(store.distanceKm)} • ${store.area}', style: text.bodyMedium),
                    const SizedBox(height: 6),
                    OpenBadge(open: open),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.schedule_rounded, label: 'Open ${store.hoursLabel}'),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.location_on_outlined, label: store.address),
          const SizedBox(height: 20),
          AppButton(
            label: 'Map & directions',
            icon: Icons.directions_outlined,
            onPressed: () => openDirections(ctx, lat: store.lat, lng: store.lng),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Show on map',
            kind: AppButtonKind.tonal,
            icon: Icons.map_outlined,
            onPressed: () {
              stores.select(store.id);
              Navigator.of(ctx).pop();
              GoRouter.of(context).go(AppRoutes.explore);
            },
          ),
        ],
      );
    },
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: context.textTheme.bodyLarge)),
        ],
      );
}
