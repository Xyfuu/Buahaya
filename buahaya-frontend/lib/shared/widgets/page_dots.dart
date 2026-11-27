import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.controller, required this.count});

  final PageController controller;
  final int count;

  double _page() {
    if (controller.hasClients && controller.position.haveDimensions) {
      return controller.page ?? controller.initialPage.toDouble();
    }
    return controller.initialPage.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = _page();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++)
              Builder(builder: (_) {
                final t = (1 - (page - i).abs()).clamp(0.0, 1.0);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6 + 10 * t,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Color.lerp(AppColors.handle, AppColors.primary, t),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
