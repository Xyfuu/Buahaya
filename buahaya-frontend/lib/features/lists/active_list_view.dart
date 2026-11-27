import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/shopping_controller.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/shopping.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/fruit_image.dart';
import '../../shared/widgets/info_banner.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../shared/widgets/quantity_stepper.dart';
import '../../shared/widgets/surface_card.dart';
import 'widgets/list_dialogs.dart';

class ActiveListView extends StatelessWidget {
  const ActiveListView({super.key, required this.list, required this.onFinished});

  final ShoppingList list;
  final VoidCallback onFinished;

  Future<void> _finish(BuildContext context) async {
    final done = await showCompleteShoppingPopup(context, list);
    if (done) onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final shopping = context.read<ShoppingController>();
    final plan = list.planItems;
    final cart = list.cartItems;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
                SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const PillBadge(
                    label: 'Active now',
                    backgroundColor: AppColors.secondaryContainer,
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Goal: ${list.fruitTypes} fruit types', style: text.bodyMedium)),
                  PopupMenuButton<String>(
                    tooltip: 'List options',
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.onSurfaceVariant),
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (v) async {
                      switch (v) {
                        case 'edit':
                          context.push(AppRoutes.addToList);
                        case 'finish':
                          _finish(context);
                        case 'delete':
                          final ok = await showDangerConfirm(context,
                              icon: Icons.delete_outline_rounded,
                              title: 'Delete this list?',
                              message: 'The list and its cart will be removed. This can’t be undone.',
                              confirmLabel: 'Yes, delete list');
                          if (ok) await shopping.deleteActive();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit fruit list')),
                      PopupMenuItem(value: 'finish', child: Text('Finish shopping')),
                      PopupMenuItem(value: 'delete', child: Text('Delete list', style: TextStyle(color: AppColors.error))),
                    ],
                  ),
                ],
              ),
              Text(list.name, style: text.titleLarge!.copyWith(fontWeight: FontWeight.w600)),
              if (list.store != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Expanded(child: Text(list.store!, style: text.bodyMedium)),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              InfoBanner(
                leading: const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                child: Text('One active list at a time. Finish this trip before creating a new shopping list.',
                    style: text.bodyMedium!.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

                if (!list.isShared) _ShopTogetherCard(list: list) else _MembersCard(list: list),
        const SizedBox(height: 20),

                Row(
          children: [
            const Icon(Icons.checklist_rounded, size: 20, color: AppColors.onSurface),
            const SizedBox(width: 8),
            Text('Shopping plan', style: text.titleMedium),
            const Spacer(),
            PillBadge(
              label: '${plan.length} ${plan.length == 1 ? 'item' : 'items'}',
              backgroundColor: AppColors.surfaceContainerHigh,
              foregroundColor: AppColors.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (plan.isEmpty)
          SurfaceCard(child: Text('Your plan is empty. Add fruit to get started.', style: text.bodyLarge)),
        for (final i in plan)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SurfaceCard(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  FruitImage(fruit: i.fruit, size: 64, radius: 10),
                  const SizedBox(width: 16),
                  Expanded(child: Text(i.fruit.name, style: text.labelMedium!.copyWith(color: AppColors.onSurface))),
                  QuantityStepper(value: i.planned, onChanged: (v) => shopping.setPlanned(i.fruit, v)),
                  IconButton(
                    tooltip: 'Remove',
                    onPressed: () => shopping.setPlanned(i.fruit, 0),
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        AppButton(
          label: 'Add fruit to list',
          icon: Icons.add_circle_outline_rounded,
          onPressed: () => context.push(AppRoutes.addToList),
        ),
        const SizedBox(height: 24),

                Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 20, color: AppColors.onSurface),
            const SizedBox(width: 8),
            Text('In cart', style: text.titleMedium),
          ],
        ),
        const SizedBox(height: 10),
        if (cart.isEmpty)
          SurfaceCard(
            child: Row(
              children: [
                const Icon(Icons.document_scanner_outlined, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text('Nothing in your cart yet. Scan fruit to add it here.', style: text.bodyLarge)),
              ],
            ),
          ),
        for (final i in cart)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SurfaceCard(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  FruitImage(fruit: i.fruit, size: 64, radius: 10),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.fruit.name, style: text.labelMedium!.copyWith(color: AppColors.onSurface)),
                        Text(i.planned > 0 ? '${i.inCart} of ${i.planned} in cart' : 'Extra item', style: text.bodyMedium),
                      ],
                    ),
                  ),
                  QuantityStepper(value: i.inCart, onChanged: (v) => shopping.setInCart(i.fruit, v)),
                  IconButton(
                    tooltip: 'Remove from cart',
                    onPressed: () => shopping.setInCart(i.fruit, 0),
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        AppButton(label: 'Finish shopping', icon: Icons.receipt_long_outlined, onPressed: () => _finish(context)),
        const SizedBox(height: 8),
        Text('Finishing saves this list to history.\nYou won’t be able to edit it.',
            textAlign: TextAlign.center, style: text.bodyMedium),
      ],
    );
  }
}

class _ShopTogetherCard extends StatelessWidget {
  const _ShopTogetherCard({required this.list});
  final ShoppingList list;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.groups_outlined, size: 18, color: AppColors.onPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shop together', style: text.labelLarge!.copyWith(letterSpacing: 0)),
                Text('Invite friends or family to plan your shopping together.', style: text.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _InviteChip(onTap: () => showInvitePartnerPopup(context, list)),
        ],
      ),
    );
  }
}

class _InviteChip extends StatelessWidget {
  const _InviteChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add_alt_1_outlined, size: 14, color: Color(0xFF015236)),
            const SizedBox(width: 4),
            Text('Invite', style: context.textTheme.labelSmall!.copyWith(color: const Color(0xFF015236))),
          ],
        ),
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.list});
  final ShoppingList list;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final shopping = context.read<ShoppingController>();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.groups_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('Shop with friends or family',
                      style: text.labelLarge!.copyWith(letterSpacing: 0))),
              _InviteChip(onTap: () => showInvitePartnerPopup(context, list)),
            ],
          ),
          const SizedBox(height: 10),
          for (final m in list.members)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: m.isPending ? AppColors.secondaryContainer : AppColors.primaryContainer,
                      child: Text(m.initials,
                          style: text.labelMedium!.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(m.name, style: text.labelMedium!.copyWith(color: AppColors.onSurface)),
                              if (m.isOwner)
                                const PillBadge(
                                    label: 'Owner • You',
                                    backgroundColor: AppColors.surfaceContainer,
                                    foregroundColor: AppColors.primary)
                              else if (m.isPending)
                                const PillBadge(
                                    label: 'Invite pending',
                                    backgroundColor: Color(0xFFFFEFC9),
                                    foregroundColor: Color(0xFF926400))
                              else
                                const PillBadge(
                                    label: 'Active',
                                    backgroundColor: Color(0xFFD1FAE5),
                                    foregroundColor: AppColors.successText),
                            ],
                          ),
                          if (m.isPending)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 12, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text('Waiting for invitation approval', style: text.bodySmall)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!m.isOwner)
                      IconButton(
                        tooltip: 'Remove ${m.name}',
                        onPressed: () async {
                          final ok = await showDangerConfirm(context,
                              icon: Icons.person_remove_outlined,
                              title: 'Remove ${m.name}?',
                              message: 'They will no longer see or edit this shopping list.',
                              confirmLabel: 'Yes, remove');
                          if (ok) await shopping.removeMember(m.id);
                        },
                        icon: const Icon(Icons.person_remove_alt_1_outlined, size: 20, color: AppColors.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () async {
              final ok = await showDangerConfirm(context,
                  icon: Icons.person_off_outlined,
                  title: 'Stop sharing?',
                  message: 'All invited members will be removed from this list.',
                  confirmLabel: 'Yes, stop sharing');
              if (ok) await shopping.stopSharing();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.group_off_outlined, size: 14, color: AppColors.error),
                  const SizedBox(width: 6),
                  Text('Stop sharing', style: text.labelSmall!.copyWith(color: AppColors.error)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
