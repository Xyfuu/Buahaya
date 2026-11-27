import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.value, required this.onChanged, required this.label});

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: value ? null : Border.all(color: AppColors.outline, width: 1.5),
              ),
              child: value
                  ? const Icon(Icons.check_rounded, size: 14, color: AppColors.onPrimary)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        label,
      ],
    );
  }
}
