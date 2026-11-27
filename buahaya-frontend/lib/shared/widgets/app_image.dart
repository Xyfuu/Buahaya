import 'dart:io';

import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    required this.fallback,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String? source;
  final Widget fallback;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final s = source;
    if (s == null || s.isEmpty) return fallback;

    if (s.startsWith('http')) {
      return Image.network(s,
          width: width, height: height, fit: fit,
          errorBuilder: (_, __, ___) => fallback);
    }
    if (s.startsWith('assets/')) {
      return Image.asset(s,
          width: width, height: height, fit: fit,
          errorBuilder: (_, __, ___) => fallback);
    }
    return Image.file(File(s),
        width: width, height: height, fit: fit,
        errorBuilder: (_, __, ___) => fallback);
  }
}
