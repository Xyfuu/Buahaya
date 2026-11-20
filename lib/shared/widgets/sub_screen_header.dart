import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_x.dart';
import '../../core/theme/app_colors.dart';

/// Header layar penuh: tombol kembali + judul.
class SubScreenHeader extends StatelessWidget {
  const SubScreenHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.leftAligned = false,
    this.titleStyle,
    this.circleBack = true,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool leftAligned;
  final TextStyle? titleStyle;
  final bool circleBack;

  @override
  Widget build(BuildContext context) {
    final style = titleStyle ?? context.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700);
    final back = Tooltip(
      message: 'Back',
      child: InkResponse(
        radius: 24,
        onTap: onBack ?? () => context.pop(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: circleBack ? const Color(0xCCFFFFFF) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 22, color: AppColors.onSurface),
        ),
      ),
    );
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            back,
            if (leftAligned) ...[
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: style)),
              if (trailing != null) trailing!,
            ] else ...[
              Expanded(child: Center(child: Text(title, style: style))),
              trailing ?? const SizedBox(width: 40),
            ],
          ],
        ),
      ),
    );
  }
}
