import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Kotak informasi (hijau muda secara default).
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.leading,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.gap = 10,
    this.color = AppColors.surfaceContainer,
    this.border,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final Widget leading;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double gap;
  final Color color;
  final BoxBorder? border;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12), border: border),
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: crossAxisAlignment,
          children: [leading, SizedBox(width: gap), Expanded(child: child)],
        ),
      ),
    );
  }
}
