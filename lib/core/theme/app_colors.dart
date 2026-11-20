import 'package:flutter/material.dart';

/// Warna hasil ekstraksi file Figma BUAHAYA (hanya layar berwarna).
abstract final class AppColors {
  // Surface
  static const background = Color(0xFFECFEF1);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFE6F8EB); // input, banner
  static const surfaceContainerHigh = Color(0xFFDBEDE0); // tab track, chip
  static const iconCircle = Color(0xFFE0F2E6);
  static const secondaryContainer = Color(0xFFCDE9DD);
  static const handle = Color(0xFFD5E7DA);
  static const outlineVariant = Color(0x4DBFC9C1);
  static const hairline = Color(0xFFE5EBE7);
  static const dangerSoftBg = Color(0xFFFEF2F2);
  static const neutralButton = Color(0xFFE6E6E6);

  // Brand
  static const primary = Color(0xFF175E41);
  static const primaryDark = Color(0xFF124D38);
  static const primaryContainer = Color(0xFFACF2CB);
  static const primarySoft = Color(0x4DACF2CB);
  static const secondary = Color(0xFF506A60);
  static const secondaryDark = Color(0xFF4A645A);
  static const cardGreen = Color(0xFF347758);
  static const mint = Color(0xFFB6FCD5);
  static const deepGreen = Color(0xFF1B4332);
  static const success = Color(0xFF10B981);
  static const successText = Color(0xFF065F46);

  // Amber
  static const amber = Color(0xFF965F00);
  static const amberDark = Color(0xFF764900);
  static const amberLight = Color(0xFFFFDDB8);
  static const amberTitle = Color(0xFFFFE9D4);
  static const amberAccent = Color(0xFFFFB95F);
  static const noteBackground = Color(0xFFFFF1E0);
  static const noteText = Color(0xFF653E00);

  // Danger
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEF2F2);

  // Text
  static const onSurface = Color(0xFF101F17);
  static const onSurfaceVariant = Color(0xFF404943);
  static const outline = Color(0xFF707972);
  static const onPrimary = Color(0xFFFFFFFF);

  // Camera
  static const cameraBackground = Color(0xFF121814);
  static const cameraOverlay = Color(0xFF24342B);

  // Overlay / toast
  static const scrim = Color(0x73022C22);
  static const toastBackground = Color(0xFF124D38);
  static const toastBody = Color(0xFFD7F1E4);
}
