import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/shopping_controller.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_toast.dart';
import '../../shared/widgets/sub_screen_header.dart';
import 'widgets/fruit_picker.dart';

/// Frame Figma "Add a new list" (judul "Add to shopping list"): ubah rencana list aktif.
class AddToListScreen extends StatefulWidget {
  const AddToListScreen({super.key});

  @override
  State<AddToListScreen> createState() => _AddToListScreenState();
}

class _AddToListScreenState extends State<AddToListScreen> {
  late final Map<String, int> _qty = {
    for (final i in context.read<ShoppingController>().active?.planItems ?? []) i.fruit.id: i.planned,
  };
  bool _saving = false;

  int get _types => _qty.values.where((v) => v > 0).length;
  int get _items => _qty.values.fold(0, (a, b) => a + b);

  void _cancel() => context.canPop() ? context.pop() : context.go(AppRoutes.lists);

  Future<void> _save() async {
    setState(() => _saving = true);
    final shopping = context.read<ShoppingController>();
    await shopping.applyPlan({for (final e in _qty.entries) if (e.value > 0) e.key: e.value});
    if (!mounted) return;
    AppToast.show(context, title: 'Shopping list updated', message: '$_items items across $_types fruit types.');
    _cancel();
  }

  @override
  Widget build(BuildContext context) {
    final shopping = context.watch<ShoppingController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SubScreenHeader(title: 'Add to shopping list', onBack: _cancel, circleBack: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  FruitPicker(
                    catalog: shopping.catalog,
                    quantities: _qty,
                    showFilter: true,
                    onChanged: (f, v) => setState(() => _qty[f.id] = v),
                  ),
                ],
              ),
            ),
            PickerFooter(types: _types, items: _items, loading: _saving, onSave: _save, onCancel: _cancel),
          ],
        ),
      ),
    );
  }
}
