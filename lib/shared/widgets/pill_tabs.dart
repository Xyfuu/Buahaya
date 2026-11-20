import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

class PillTab {
  const PillTab(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Segmented control berbentuk pil (Log in | Sign up, Active list | History).
class PillTabs extends StatelessWidget {
  const PillTabs({super.key, required this.tabs, required this.selectedIndex, required this.onChanged});

  final List<PillTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? AppColors.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: i == selectedIndex ? AppShadows.card : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tabs[i].icon,
                          size: 15,
                          color: i == selectedIndex ? AppColors.primary : AppColors.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        tabs[i].label,
                        style: context.textTheme.labelMedium!.copyWith(
                          color: i == selectedIndex ? AppColors.primary : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
