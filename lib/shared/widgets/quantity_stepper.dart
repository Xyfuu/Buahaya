import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/theme/app_colors.dart';

/// Stepper "− 4 +" berbentuk pil.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundButton(
            icon: Icons.remove_rounded,
            onTap: value > min ? () => onChanged(value - 1) : null,
            filled: false,
          ),
          SizedBox(
            width: 30,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: context.textTheme.labelMedium!.copyWith(color: AppColors.onSurface)),
          ),
          _RoundButton(
            icon: Icons.add_rounded,
            onTap: value < max ? () => onChanged(value + 1) : null,
            filled: true,
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap, required this.filled});

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? (enabled ? AppColors.primary : AppColors.handle) : Colors.transparent,
        ),
        child: Icon(icon,
            size: 15,
            color: filled
                ? AppColors.onPrimary
                : (enabled ? AppColors.onSurface : AppColors.outline)),
      ),
    );
  }
}
