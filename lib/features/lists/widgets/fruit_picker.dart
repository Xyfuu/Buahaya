import 'package:flutter/material.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/fruit.dart';
import '../../../shared/widgets/fruit_image.dart';
import '../../../shared/widgets/quantity_stepper.dart';
import '../../../shared/widgets/surface_card.dart';

/// Pencarian + daftar "Choose fresh fruit" dengan stepper / tombol "+ Add".
class FruitPicker extends StatefulWidget {
  const FruitPicker({
    super.key,
    required this.catalog,
    required this.quantities,
    required this.onChanged,
    this.showFilter = false,
  });

  final List<Fruit> catalog;
  final Map<String, int> quantities;
  final void Function(Fruit fruit, int qty) onChanged;
  final bool showFilter;

  @override
  State<FruitPicker> createState() => _FruitPickerState();
}

class _FruitPickerState extends State<FruitPicker> {
  String _query = '';
  bool _selectedOnly = false;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final q = _query.trim().toLowerCase();
    final fruits = widget.catalog.where((f) {
      if (q.isNotEmpty && !f.name.toLowerCase().contains(q)) return false;
      if (_selectedOnly && (widget.quantities[f.id] ?? 0) == 0) return false;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          padding: const EdgeInsets.only(left: 14, right: 6),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, size: 20, color: AppColors.onSurface),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: text.bodyLarge!.copyWith(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search fruit (apples, oranges, mangoes...)',
                    hintStyle: text.bodyLarge!.copyWith(color: AppColors.outline, fontSize: 13),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (widget.showFilter)
                InkResponse(
                  onTap: () => setState(() => _selectedOnly = !_selectedOnly),
                  radius: 20,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: _selectedOnly ? AppColors.primaryContainer : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.tune_rounded, size: 18, color: _selectedOnly ? AppColors.primary : AppColors.onSurfaceVariant),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Choose fresh fruit', style: text.labelLarge!.copyWith(fontWeight: FontWeight.w700)),
            if (_selectedOnly) ...[
              const SizedBox(width: 8),
              Text('(selected only)', style: text.bodyMedium),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (fruits.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No fruit found.', style: text.bodyLarge)),
          ),
        for (final f in fruits)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SurfaceCard(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  FruitImage(fruit: f, size: 64, radius: 10),
                  const SizedBox(width: 16),
                  Expanded(child: Text(f.name, style: text.labelLarge!.copyWith(color: AppColors.onSurface))),
                  if ((widget.quantities[f.id] ?? 0) > 0)
                    QuantityStepper(
                      value: widget.quantities[f.id]!,
                      onChanged: (v) => widget.onChanged(f, v),
                    )
                  else
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => widget.onChanged(f, 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(999)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text('Add', style: text.labelMedium!.copyWith(color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Footer tetap: ringkasan pilihan + tombol simpan + batal.
class PickerFooter extends StatelessWidget {
  const PickerFooter({
    super.key,
    required this.types,
    required this.items,
    required this.onSave,
    required this.onCancel,
    this.enabled = true,
    this.loading = false,
  });

  final int types;
  final int items;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 8 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 18, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text('$types fruit ${types == 1 ? 'type' : 'types'} selected',
                  style: text.labelMedium!.copyWith(color: AppColors.onSurface)),
              const Spacer(),
              Text('$items ${items == 1 ? 'item' : 'items'}',
                  style: text.titleMedium!.copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          AppButtonHost(
            label: 'Save and start shopping',
            enabled: enabled,
            loading: loading,
            onTap: onSave,
          ),
          TextButton(
            onPressed: onCancel,
            child: Text('Cancel', style: text.labelMedium!.copyWith(color: AppColors.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

/// Tombol primer kecil agar import AppButton tetap lokal.
class AppButtonHost extends StatelessWidget {
  const AppButtonHost({super.key, required this.label, required this.enabled, required this.loading, required this.onTap});

  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: enabled && !loading ? onTap : null,
        icon: loading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.check_rounded, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: const Color(0xFFDCE5DF),
          disabledForegroundColor: const Color(0xFF8A948D),
          shape: const StadiumBorder(),
          textStyle: context.textTheme.labelLarge,
          elevation: 0,
        ),
      ),
    );
  }
}
