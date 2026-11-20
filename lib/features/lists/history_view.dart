import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/shopping_controller.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/shopping.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/fruit_image.dart';
import '../../shared/widgets/info_banner.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../shared/widgets/surface_card.dart';
import 'empty_list_view.dart';
import 'widgets/haul_preview_sheet.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final shopping = context.watch<ShoppingController>();
    final trips = shopping.history;

    final banner = InfoBanner(
      color: AppColors.surfaceContainerHigh,
      padding: const EdgeInsets.all(14),
      leading: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
        child: const Icon(Icons.history_toggle_off_rounded, size: 16, color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Shopping history', style: text.labelMedium!.copyWith(color: AppColors.primary)),
          Text('Finished shopping lists are saved here.\nThey can no longer be edited.', style: text.bodyMedium),
        ],
      ),
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        banner,
        const SizedBox(height: 14),
        if (trips.isEmpty) ..._empty(context) else ..._content(context, shopping),
      ],
    );
  }

  List<Widget> _empty(BuildContext context) {
    final text = context.textTheme;
    Widget tile(IconData icon, Color bg, String title, String body) => SurfaceCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.labelLarge!.copyWith(letterSpacing: 0, color: AppColors.onSurface)),
                    const SizedBox(height: 2),
                    Text(body, style: text.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );

    return [
      SurfaceCard(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          children: [
            const BasketIllustration(),
            const SizedBox(height: 12),
            Text('No shopping history yet', style: text.titleLarge!.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'You haven’t finished a shopping trip yet.\nFinish your active list or start a new trip\nto save your shopping history and\nshare your fruit haul!',
              textAlign: TextAlign.center,
              style: text.bodyLarge,
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Create a shopping list',
              icon: Icons.shopping_cart_outlined,
              onPressed: () => context.push(AppRoutes.createList),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Scan and check fruit',
              icon: Icons.document_scanner_outlined,
              kind: AppButtonKind.tonal,
              onPressed: () => context.push(AppRoutes.scan),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.onSurface),
                const SizedBox(width: 8),
                Text('Why save your trips?', style: text.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            tile(Icons.photo_library_outlined, const Color(0xFFFFDDB8), 'Share your fruit haul',
                'After shopping, share your fruit haul to your Instagram Story or social media in one tap.'),
            const SizedBox(height: 8),
            tile(Icons.trending_up_rounded, AppColors.secondaryContainer, 'Track your fruit intake',
                'Track your family’s weekly fruit intake and save money.'),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco_outlined, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text('Pick the right fruit, Avoid the BUAHAYA!', style: text.bodyLarge),
        ],
      ),
    ];
  }

  List<Widget> _content(BuildContext context, ShoppingController shopping) {
    final text = context.textTheme;
    Widget stat(IconData icon, String label, String value) => Expanded(
          child: SurfaceCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: text.labelSmall!.copyWith(color: AppColors.onSurfaceVariant)),
                      Text(value, style: text.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

    return [
      Row(
        children: [
          stat(Icons.shopping_bag_outlined, 'TOTAL FRUIT\nBOUGHT', '${shopping.totalFruitsBought} fruits'),
          const SizedBox(width: 12),
          stat(Icons.timer_outlined, 'AVERAGE\nTIME', formatDuration(shopping.averageDuration)),
        ],
      ),
      const SizedBox(height: 14),
      for (final t in shopping.history)
        Padding(padding: const EdgeInsets.only(bottom: 14), child: _TripCard(trip: t)),
    ];
  }
}

class _TripCard extends StatefulWidget {
  const _TripCard({required this.trip});
  final ShoppingTrip trip;

  @override
  State<_TripCard> createState() => _TripCardState();
}

class _TripCardState extends State<_TripCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final t = widget.trip;
    final shown = t.fruits.take(3).toList();
    final more = t.fruits.length - shown.length;

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PillBadge(
                label: 'Done',
                icon: Icons.check_circle_rounded,
                backgroundColor: AppColors.secondaryContainer,
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(formatDate(t.finishedAt), style: text.bodyMedium)),
              InkResponse(
                radius: 20,
                onTap: () => setState(() => _expanded = !_expanded),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(8)),
                  child: Icon(_expanded ? Icons.expand_less_rounded : Icons.storefront_outlined,
                      size: 18, color: AppColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(t.name, style: text.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(formatDuration(t.duration), style: text.labelMedium!.copyWith(color: AppColors.onSurfaceVariant)),
                const Spacer(),
                Text('${t.totalFruits} fruits', style: text.labelMedium!.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !_expanded
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (t.store != null)
                          Row(children: [
                            const Icon(Icons.storefront_outlined, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(t.store!, style: text.bodyMedium),
                          ]),
                        if (t.partners.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(children: [
                            Text('With:', style: text.bodyMedium),
                            const SizedBox(width: 8),
                            for (final p in t.partners)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: PillBadge(
                                    label: p,
                                    backgroundColor: AppColors.surfaceContainerHigh,
                                    foregroundColor: AppColors.onSurface),
                              ),
                          ]),
                        ],
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.event_available_outlined, size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Text('Finished at ${t.finishedAt.hour.toString().padLeft(2, '0')}:${t.finishedAt.minute.toString().padLeft(2, '0')}',
                              style: text.bodyMedium),
                        ]),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < shown.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _TripFruitTile(tf: shown[i], more: i == shown.length - 1 ? more : 0)),
              ],
            ],
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Share your fruit haul',
            icon: Icons.auto_awesome_rounded,
            onPressed: () => showHaulPreviewSheet(context, t),
          ),
        ],
      ),
    );
  }
}

class _TripFruitTile extends StatelessWidget {
  const _TripFruitTile({required this.tf, this.more = 0});
  final TripFruit tf;
  final int more;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (_, c) => Stack(
                fit: StackFit.expand,
                children: [
                  FruitImage(fruit: tf.fruit, size: c.maxWidth, radius: 10),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${tf.count}x',
                          style: text.labelSmall!.copyWith(color: const Color(0xFFE3F5E8))),
                    ),
                  ),
                  if (more > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: PillBadge(
                        label: '+$more',
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(tf.fruit.name,
              textAlign: TextAlign.center,
              style: text.labelMedium!.copyWith(color: AppColors.onSurface)),
        ],
      ),
    );
  }
}
