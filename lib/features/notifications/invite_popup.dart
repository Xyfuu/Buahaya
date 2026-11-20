import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/notification_controller.dart';
import '../../controllers/shopping_controller.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/invite.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_popups.dart';
import '../../shared/widgets/app_toast.dart';

/// Pop-up notifikasi (lonceng): undangan shopping list. Tombol Reject / Accept.
Future<void> showInvitePopup(BuildContext context) {
  return showPopup<void>(
    context,
    alignment: Alignment.topCenter,
    margin: const EdgeInsets.fromLTRB(16, 64, 16, 0),
    maxWidth: 380,
    builder: (ctx) => _InviteCard(rootContext: context),
  );
}

class _InviteCard extends StatefulWidget {
  const _InviteCard({required this.rootContext});

  final BuildContext rootContext;

  @override
  State<_InviteCard> createState() => _InviteCardState();
}

class _InviteCardState extends State<_InviteCard> {
  bool _busy = false;

  Future<void> _respond(ListInvite invite, bool accept) async {
    final shopping = context.read<ShoppingController>();
    final notifications = context.read<NotificationController>();
    final root = widget.rootContext;
    final nav = Navigator.of(context);

    if (accept && shopping.hasActive) {
      nav.pop();
      AppToast.show(root,
          title: 'You already have an active list',
          message: 'Finish your current shopping list before joining another.',
          error: true);
      return;
    }
    setState(() => _busy = true);
    final joined = await notifications.respond(invite, accept: accept);
    nav.pop();
    if (accept && joined != null) {
      shopping.joinShared(joined);
      if (root.mounted) {
        AppToast.show(root, title: 'You joined “${invite.listName}”', message: 'The list is now your active list.');
        GoRouter.of(root).go(AppRoutes.lists);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final invite = context.watch<NotificationController>().latest;

    return PopupCard(
      padding: const EdgeInsets.all(20),
      child: invite == null
          ? Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColors.surfaceContainer, shape: BoxShape.circle),
                  child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No new notifications', style: text.labelLarge),
                      Text('You’re all caught up.', style: text.bodyMedium),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${invite.inviterName} invited you to join their shopping list',
                    style: text.bodyLarge!.copyWith(fontSize: 13, color: const Color(0xFF5C6861))),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
                  child: Text(invite.listName, style: text.labelLarge!.copyWith(color: AppColors.primary)),
                ),
                const SizedBox(height: 10),
                Text(timeAgo(invite.receivedAt),
                    style: text.bodySmall!.copyWith(color: const Color(0xFF5C6861))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Reject',
                        kind: AppButtonKind.neutral,
                        height: 44,
                        onPressed: _busy ? null : () => _respond(invite, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Accept',
                        height: 44,
                        loading: _busy,
                        onPressed: () => _respond(invite, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
