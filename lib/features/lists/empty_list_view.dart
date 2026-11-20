import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/profile_controller.dart';
import '../../controllers/shopping_controller.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_toast.dart';
import '../../shared/widgets/surface_card.dart';

/// Ilustrasi keranjang untuk empty state.
class BasketIllustration extends StatelessWidget {
  const BasketIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4))]),
            alignment: Alignment.center,
            child: const Text('🧺', style: TextStyle(fontSize: 36)),
          ),
          const Positioned(top: 4, right: 18, child: Text('✨', style: TextStyle(fontSize: 18))),
        ],
      ),
    );
  }
}

/// State "Shopping list – Empty": ajakan membuat list + form Shop with friends.
class EmptyListView extends StatefulWidget {
  const EmptyListView({super.key});

  @override
  State<EmptyListView> createState() => _EmptyListViewState();
}

class _EmptyListViewState extends State<EmptyListView> {
  final _who = TextEditingController();
  final _name = TextEditingController();
  String? _whoError;
  String? _nameError;
  bool _busy = false;

  @override
  void dispose() {
    _who.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _inviteAndStart() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _whoError = _who.text.trim().isEmpty ? 'Required' : null;
      _nameError = _name.text.trim().isEmpty ? 'Required' : null;
    });
    if (_whoError != null || _nameError != null) return;
    final owner = context.read<ProfileController>().profile;
    if (owner == null) return;
    setState(() => _busy = true);
    final who = _who.text.trim();
    await context.read<ShoppingController>().createSharedList(identifier: who, name: _name.text, owner: owner);
    if (!mounted) return;
    AppToast.show(context, title: 'Shared list created', message: 'Invitation sent to $who.');
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        SurfaceCard(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              const BasketIllustration(),
              const SizedBox(height: 12),
              Text('No active shopping list', style: text.titleLarge!.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                'You don’t have an active shopping list.\nCreate a new list or choose a template\nto plan your trip and check\nyour fruit’s freshness.',
                textAlign: TextAlign.center,
                style: text.bodyLarge,
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Create a shopping list',
                icon: Icons.shopping_cart_outlined,
                onPressed: () => context.push(AppRoutes.createList),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        Text('Shop with friends or family', style: text.labelLarge!.copyWith(letterSpacing: 0)),
                        Text('Invite friends or family to\nplan your shopping together.',
                            style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    AppTextField(
                      label: 'Friend’s username or email',
                      hint: '@username or email',
                      prefixIcon: Icons.person_outline_rounded,
                      controller: _who,
                      dense: true,
                      errorText: _whoError,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      label: 'Shared list name',
                      hint: 'Example: Shopping with Abdul',
                      prefixIcon: Icons.notes_rounded,
                      controller: _name,
                      dense: true,
                      errorText: _nameError,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _inviteAndStart(),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Invite and start sharing',
                      icon: Icons.group_add_outlined,
                      height: 44,
                      loading: _busy,
                      textStyle: text.labelMedium,
                      onPressed: _inviteAndStart,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('Once invited, friends can view and edit the shopping list in real time.',
                              style: text.bodySmall),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
