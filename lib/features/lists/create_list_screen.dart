import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/profile_controller.dart';
import '../../controllers/shopping_controller.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_toast.dart';
import '../../shared/widgets/sub_screen_header.dart';
import '../../shared/widgets/surface_card.dart';
import 'widgets/fruit_picker.dart';

class CreateListScreen extends StatefulWidget {
  const CreateListScreen({super.key});

  @override
  State<CreateListScreen> createState() => _CreateListScreenState();
}

class _CreateListScreenState extends State<CreateListScreen> {
  final _name = TextEditingController();
  final _store = TextEditingController();
  final Map<String, int> _qty = {};
  String? _nameError;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _store.dispose();
    super.dispose();
  }

  int get _types => _qty.values.where((v) => v > 0).length;
  int get _items => _qty.values.fold(0, (a, b) => a + b);

  void _cancel() => context.canPop() ? context.pop() : context.go(AppRoutes.home);

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = 'Required');
      return;
    }
    if (_types == 0) {
      AppToast.show(context, title: 'Pick at least one fruit', message: 'Add a fruit to start shopping.', error: true);
      return;
    }
    final owner = context.read<ProfileController>().profile;
    if (owner == null) return;
    setState(() => _saving = true);
    await context.read<ShoppingController>().createList(
          name: _name.text,
          store: _store.text,
          quantities: _qty,
          owner: owner,
        );
    if (!mounted) return;
    context.go(AppRoutes.lists);
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final catalog = context.watch<ShoppingController>().catalog;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SubScreenHeader(title: 'Create a shopping list', onBack: _cancel, circleBack: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notes_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('SHOPPING PLAN DETAILS',
                                style: text.labelMedium!.copyWith(color: AppColors.primary, letterSpacing: 0.6)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'List name',
                          hint: 'Weekly fresh fruit',
                          controller: _name,
                          errorText: _nameError,
                          labelStyle: text.labelMedium!.copyWith(color: AppColors.onSurfaceVariant),
                          onChanged: (_) => setState(() => _nameError = null),
                          suffix: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Store or location (optional)',
                          hint: 'Grand Lucky Supermarket',
                          controller: _store,
                          labelStyle: text.labelMedium!.copyWith(color: AppColors.onSurfaceVariant),
                          suffix: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FruitPicker(
                    catalog: catalog,
                    quantities: _qty,
                    onChanged: (f, v) => setState(() => _qty[f.id] = v),
                  ),
                ],
              ),
            ),
            PickerFooter(
              types: _types,
              items: _items,
              loading: _saving,
              onSave: _save,
              onCancel: _cancel,
            ),
          ],
        ),
      ),
    );
  }
}
