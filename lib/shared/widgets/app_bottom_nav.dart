import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTab,
    required this.onScan,
  });

  static const double barHeight = 64;
  static const double fabOverhang = 21;

  final int currentIndex;
  final ValueChanged<int> onTab;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return SizedBox(
      height: barHeight + fabOverhang + bottom,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight + bottom,
            child: DecoratedBox(
              decoration: const BoxDecoration(boxShadow: AppShadows.navBar),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: const Color(0xF2FFFFFF),
                    padding: EdgeInsets.only(bottom: bottom),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Row(
                        children: [
                          _Item(Icons.home_outlined, Icons.home_rounded, 'Home', currentIndex == 0, () => onTab(0)),
                          _Item(Icons.checklist_rounded, Icons.checklist_rounded, 'Lists', currentIndex == 1, () => onTab(1)),
                          const Expanded(child: SizedBox()),
                          _Item(Icons.storefront_outlined, Icons.storefront_rounded, 'Explore', currentIndex == 2, () => onTab(2)),
                          _Item(Icons.person_outline_rounded, Icons.person_rounded, 'Profile', currentIndex == 3, () => onTab(3)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onScan,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle, boxShadow: AppShadows.fab),
                      child: const Icon(Icons.document_scanner_outlined, size: 26, color: AppColors.onPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text('Scan fruit',
                        style: context.textTheme.labelSmall!
                            .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
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

class _Item extends StatelessWidget {
  const _Item(this.icon, this.activeIcon, this.label, this.selected, this.onTap);

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.cardGreen : AppColors.onSurfaceVariant;
    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? activeIcon : icon, size: 22, color: color),
              const SizedBox(height: 2),
              Text(label, style: context.textTheme.labelSmall!.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
