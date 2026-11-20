import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';

class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
    this.iconSize = 12,
    this.leading,
    this.gap = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    this.textStyle,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData? icon;
  final double iconSize;
  final Widget? leading;
  final double gap;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final style = (textStyle ?? context.textTheme.labelSmall!).copyWith(color: foregroundColor);
    final Widget? lead = icon != null ? Icon(icon, size: iconSize, color: foregroundColor) : leading;
    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(999)),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lead != null) ...[lead, SizedBox(width: gap)],
            Flexible(child: Text(label, style: style, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
