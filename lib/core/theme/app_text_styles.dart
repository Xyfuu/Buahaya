import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografi Buahaya (Plus Jakarta Sans).
///
/// headlineLarge 35 Bold | headlineMedium 24 Bold | titleLarge 20 Bold
/// titleMedium 18 SemiBold | titleSmall 16 Bold
/// bodyLarge 14 | bodyMedium 12 | bodySmall 11
/// labelLarge 14 SemiBold | labelMedium 12 SemiBold | labelSmall 10 Bold
abstract final class AppTextStyles {
  static TextStyle _s(double size, FontWeight w,
      {double? height, double ls = 0, Color color = AppColors.onSurface}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: w,
      height: height == null ? null : height / size,
      letterSpacing: ls,
      color: color,
    );
  }

  static TextStyle get headlineLarge => _s(35, FontWeight.w700, height: 42, ls: -0.9);
  static TextStyle get headlineMedium => _s(24, FontWeight.w700, height: 32);
  static TextStyle get titleLarge => _s(20, FontWeight.w700, height: 26);
  static TextStyle get titleMedium => _s(18, FontWeight.w600, height: 24);
  static TextStyle get titleSmall => _s(16, FontWeight.w700, height: 22);
  static TextStyle get bodyLarge => _s(14, FontWeight.w400, height: 20, color: AppColors.onSurfaceVariant);
  static TextStyle get bodyMedium => _s(12, FontWeight.w400, height: 17, color: AppColors.onSurfaceVariant);
  static TextStyle get bodySmall => _s(11, FontWeight.w400, height: 15, color: AppColors.onSurfaceVariant);
  static TextStyle get labelLarge => _s(14, FontWeight.w600, height: 20, ls: 0.14);
  static TextStyle get labelMedium => _s(12, FontWeight.w600, height: 16, ls: 0.24);
  static TextStyle get labelSmall => _s(10, FontWeight.w700, height: 14, ls: 0.4);

  static TextTheme get textTheme => TextTheme(
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
