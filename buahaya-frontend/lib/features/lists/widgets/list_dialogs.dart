import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/shopping_controller.dart';
import '../../../core/extensions/context_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/shopping.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_popups.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/pill_badge.dart';

Future<bool> showCompleteShoppingPopup(BuildContext context, ShoppingList list) async {
  final shopping = context.read<ShoppingController>();
  final verified = list.planItems.where((i) => i.inCart > 0).toList();
  final unchecked = list.planItems.length - verified.length;

  final result = await showPopup<bool>(
    context,
    builder: (ctx) {
      final text = ctx.textTheme;
      return ConfirmPopup(
        icon: Icons.shopping_bag_outlined,
        title: 'Complete Shopping?',
        message: 'Your shopping list will be moved to history and marked as completed.',
        extra: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Items in Cart', style: text.labelSmall!.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600))),
                  PillBadge(
                    label: '${verified.length} of ${list.planItems.length} verified',
                    backgroundColor: AppColors.secondaryContainer,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (list.cartItems.isEmpty)
                Text('Nothing in your cart yet.', style: text.bodyMedium)
              else
                for (final i in list.cartItems)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${i.fruit.name}  •  ${i.inCart} items verified',
                              style: text.bodyMedium!.copyWith(color: AppColors.onSurface)),
                        ),
                      ],
                    ),
                  ),
              if (unchecked > 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 15, color: AppColors.amber),
                    const SizedBox(width: 6),
                    Text('$unchecked ${unchecked == 1 ? 'item remains' : 'items remain'} unchecked',
                        style: text.bodySmall!.copyWith(color: AppColors.amber)),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          AppButton(
            label: 'Yes, Complete Shopping',
            icon: Icons.check_rounded,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
          AppButton(label: 'Keep Shopping', kind: AppButtonKind.neutral, onPressed: () => Navigator.of(ctx).pop(false)),
        ],
      );
    },
  );
  if (result != true) return false;
  await shopping.finish();
  if (context.mounted) {
    AppToast.show(context, title: 'Shopping completed', message: 'Your trip was saved to History.');
  }
  return true;
}

Future<void> showInvitePartnerPopup(BuildContext context, ShoppingList list) {
  return showPopup<void>(
    context,
    builder: (ctx) => _InvitePartnerCard(list: list, parentContext: context),
  );
}

class _InvitePartnerCard extends StatefulWidget {
  const _InvitePartnerCard({required this.list, required this.parentContext});

  final ShoppingList list;
  final BuildContext parentContext;

  @override
  State<_InvitePartnerCard> createState() => _InvitePartnerCardState();
}

class _InvitePartnerCardState extends State<_InvitePartnerCard> {
  final _who = TextEditingController();
  late final _name = TextEditingController(text: widget.list.name);
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _who.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final shopping = context.read<ShoppingController>();
    final root = widget.parentContext;
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await shopping.invite(_who.text);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _busy = false;
        _error = err;
      });
      return;
    }
    await shopping.renameActive(_name.text);
    if (!mounted) return;
    final who = _who.text.trim();
    Navigator.of(context).pop();
    if (root.mounted) AppToast.show(root, title: 'Invitation sent', message: '$who can now join your list.');
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return PopupCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
                child: const Icon(Icons.group_add_outlined, size: 17, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('Invite friends to shop together', style: text.labelLarge)),
              InkResponse(
                onTap: () => Navigator.of(context).pop(),
                radius: 18,
                child: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const Divider(height: 24),
          AppTextField(
            label: 'Friend’s username or email',
            hint: '@username or email',
            prefixIcon: Icons.person_outline_rounded,
            controller: _who,
            dense: true,
            errorText: _error,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Shared list name',
            hint: 'Example: Weekly shopping',
            prefixIcon: Icons.notes_rounded,
            controller: _name,
            dense: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _send(),
          ),
          const SizedBox(height: 16),
          AppButton(
              label: 'Invite and start sharing',
              icon: Icons.group_add_outlined,
              height: 44,
              loading: _busy,
              textStyle: text.labelMedium,
              onPressed: _send),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Once invited, friends can check off items and view the cart in real time.',
                    style: text.bodySmall),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<bool> showDangerConfirm(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
}) async {
  final ok = await showPopup<bool>(
    context,
    builder: (ctx) => ConfirmPopup(
      icon: icon,
      iconColor: AppColors.error,
      iconBackground: AppColors.dangerSoft,
      title: title,
      message: message,
      actions: [
        AppButton(label: confirmLabel, kind: AppButtonKind.danger, onPressed: () => Navigator.of(ctx).pop(true)),
        AppButton(label: cancelLabel, kind: AppButtonKind.neutral, onPressed: () => Navigator.of(ctx).pop(false)),
      ],
    ),
  );
  return ok == true;
}
