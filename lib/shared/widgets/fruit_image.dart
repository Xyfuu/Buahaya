import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/fruit.dart';
import 'app_image.dart';

/// Gambar buah: foto dari aset/URL, atau emoji jika belum ada.
class FruitImage extends StatelessWidget {
  const FruitImage({super.key, required this.fruit, this.size = 56, this.radius = 12});

  final Fruit fruit;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: AppColors.surfaceContainer,
      child: Text(fruit.emoji, style: TextStyle(fontSize: size * 0.52)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AppImage(
        source: fruit.imageUrl,
        width: size,
        height: size,
        fallback: fallback,
      ),
    );
  }
}
