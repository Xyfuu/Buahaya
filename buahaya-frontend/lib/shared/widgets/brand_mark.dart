import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import 'app_image.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 80,
    this.shadow = true,
    this.showCircles = true,
    this.imagePath = AppAssets.logo,
  });

  final double size;
  final bool shadow;
  final bool showCircles;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    if (!showCircles) {
      return SizedBox(
        width: size,
        height: size,
        child: AppImage(
          source: imagePath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          fallback: _fallbackIcon(size),
        ),
      );
    }

        final middle = size * 0.8;
    final logo = middle * 0.72;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: shadow ? AppShadows.elevated : null,
      ),
      child: Container(
        width: middle,
        height: middle,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: AppImage(
          source: imagePath,
          width: logo,
          height: logo,
          fit: BoxFit.contain,
          fallback: _fallbackIcon(logo),
        ),
      ),
    );
  }

    Widget _fallbackIcon(double s) => Icon(
        Icons.check_circle_rounded,
        size: s,
        color: AppColors.primary,
      );
}
