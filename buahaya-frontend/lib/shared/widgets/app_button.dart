import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

enum AppButtonKind { primary, tonal, neutral, danger, dangerSoft, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.primary,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = true,
    this.height = 48,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool expand;
  final double height;
  final TextStyle? textStyle;

  (Color, Color) get _colors => switch (kind) {
        AppButtonKind.primary => (AppColors.primary, AppColors.onPrimary),
        AppButtonKind.tonal => (AppColors.secondaryContainer, AppColors.primary),
        AppButtonKind.neutral => (AppColors.neutralButton, AppColors.onSurfaceVariant),
        AppButtonKind.danger => (AppColors.danger, AppColors.onPrimary),
        AppButtonKind.dangerSoft => (AppColors.errorContainer, AppColors.onErrorContainer),
        AppButtonKind.ghost => (Colors.transparent, AppColors.onSurfaceVariant),
      };

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    var (bg, fg) = _colors;
    if (onPressed == null && !loading && kind != AppButtonKind.ghost) {
      bg = const Color(0xFFDCE5DF);
      fg = const Color(0xFF8A948D);
    }
    final style = (textStyle ?? context.textTheme.labelLarge!).copyWith(color: fg);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else ...[
          if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 8)],
          Flexible(child: Text(label, style: style, overflow: TextOverflow.ellipsis)),
          if (trailingIcon != null) ...[const SizedBox(width: 8), Icon(trailingIcon, size: 16, color: fg)],
        ],
      ],
    );

    return SizedBox(
      width: expand ? double.infinity : null,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: kind == AppButtonKind.primary && enabled ? AppShadows.elevated : null,
        ),
        child: Material(
          color: bg,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(widthFactor: expand ? null : 1, child: content),
            ),
          ),
        ),
      ),
    );
  }
}
