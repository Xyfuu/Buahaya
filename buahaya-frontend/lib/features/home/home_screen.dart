import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/notification_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/shopping_controller.dart';
import '../../controllers/store_controller.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/shopping.dart';
import '../../domain/models/store.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/page_dots.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../shared/widgets/surface_card.dart';
import '../explore/store_detail_sheet.dart';
import 'guide_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    final _pager = PageController(viewportFraction: 0.8);

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  Future<void> _refresh() => Future.wait([
        context.read<ShoppingController>().load(),
        context.read<StoreController>().load(),
        context.read<NotificationController>().load(),
        context.read<ProfileController>().load(),
      ]);

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final firstName = context.select<ProfileController, String>((c) => c.profile?.firstName ?? '');
    final stores = context.watch<StoreController>().nearest(2);

    final cards = [
      GuideCardData(
        icon: Icons.document_scanner_outlined,
        title: 'How to spot fruit\nthat is safe to eat',
        description: 'Use Buahaya’s smart camera\nto check how fresh your fruit is.',
        caption: 'Instant check',
        actionLabel: 'Start scan',
        actionIcon: Icons.photo_camera_outlined,
        style: GuideStyle.green,
        onAction: () => context.push(AppRoutes.scan),
      ),
      GuideCardData(
        icon: Icons.shopping_basket_outlined,
        title: 'Shop smart, waste less',
        description:
            'Keep track of the fruits you need and organize your shopping list before your next trip to the store.',
        caption: 'Manage yours',
        actionLabel: 'Shopping List',
        style: GuideStyle.amber,
        onAction: () => context.go(AppRoutes.lists),
      ),
      GuideCardData(
        icon: Icons.location_on_outlined,
        title: 'Your local fruit hunt',
        description:
            'Discover fruit stores around you, check their locations, and find the nearest spots for your next fresh fruit shopping.',
        caption: 'Explore',
        actionLabel: 'Nearby Stores',
        style: GuideStyle.slate,
        onAction: () => context.go(AppRoutes.explore),
      ),
    ];

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(firstName.isEmpty ? 'Hi! 😄' : 'Hi, $firstName! 😄', style: text.headlineLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text('What fresh fruit would you like today?', style: text.bodyLarge),
          ),
          SizedBox(
            height: 192,
            child: PageView.builder(
              controller: _pager,
              padEnds: false,
              itemCount: cards.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(left: 16),
                child: GuideCard(data: cards[i]),
              ),
            ),
          ),
          const SizedBox(height: 10),
          PageDots(controller: _pager, count: cards.length),
          const SizedBox(height: 16),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: _ActiveListCard()),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nearby fruit stores', style: text.titleMedium),
                      const SizedBox(height: 2),
                      Text('Find fruit stores close to\nyour current location.', style: text.bodyMedium),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.go(AppRoutes.explore),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    child: Row(
                      children: [
                        Text('View all', style: text.labelMedium!.copyWith(color: AppColors.primary)),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final s in stores)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _StoreTile(store: s),
            ),
        ],
      ),
    );
  }
}

class _ActiveListCard extends StatelessWidget {
  const _ActiveListCard();

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final list = context.select<ShoppingController, ShoppingList?>((c) => c.active);
    final has = list != null;

    return SurfaceCard(
      onTap: () => context.go(AppRoutes.lists),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
            child: const Icon(Icons.group_outlined, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(has ? 'Active Shopping List' : 'No Active Shopping List', style: text.titleSmall),
                if (has)
                  Text('${list.members.length} ${plural(list.members.length, 'member')} in the shopping list',
                      style: text.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (has)
            const PillBadge(
              label: 'Active',
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              leading: SizedBox(
                width: 6,
                height: 6,
                child: DecoratedBox(
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              ),
              gap: 6,
            )
          else
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => context.push(AppRoutes.createList),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                    color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(999)),
                child: Text('+ Create', style: text.labelMedium!.copyWith(color: AppColors.primary)),
              ),
            ),
        ],
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({required this.store});
  final FruitStore store;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      onTap: () => showStoreDetailSheet(context, store),
      child: Row(
        children: [
          StoreImage(store: store, size: 80),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                        child: Text(store.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleMedium)),
                    const SizedBox(width: 8),
                    OpenBadge(open: store.isOpenAt(DateTime.now())),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(formatDistance(store.distanceKm), style: text.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
