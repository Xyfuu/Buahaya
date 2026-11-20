import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../shared/widgets/glow_blob.dart';

class GuideStyle {
  const GuideStyle({
    required this.background,
    required this.titleColor,
    required this.bodyColor,
    required this.captionColor,
    required this.buttonBackground,
    required this.buttonForeground,
    required this.iconColor,
    required this.blob,
  });

  final Color background, titleColor, bodyColor, captionColor;
  final Color buttonBackground, buttonForeground, iconColor, blob;

  static const green = GuideStyle(
    background: AppColors.cardGreen,
    titleColor: AppColors.onPrimary,
    bodyColor: AppColors.mint,
    captionColor: AppColors.primaryContainer,
    buttonBackground: AppColors.background,
    buttonForeground: AppColors.primary,
    iconColor: AppColors.primaryContainer,
    blob: Color(0x1AFFFFFF),
  );
  static const amber = GuideStyle(
    background: AppColors.amber,
    titleColor: AppColors.amberTitle,
    bodyColor: AppColors.amberLight,
    captionColor: AppColors.amberLight,
    buttonBackground: AppColors.onPrimary,
    buttonForeground: AppColors.amberDark,
    iconColor: AppColors.amberLight,
    blob: Color(0x33FFDDB8),
  );
  static const slate = GuideStyle(
    background: AppColors.secondaryDark,
    titleColor: AppColors.onPrimary,
    bodyColor: AppColors.secondaryContainer,
    captionColor: AppColors.secondaryContainer,
    buttonBackground: AppColors.background,
    buttonForeground: AppColors.secondaryDark,
    iconColor: AppColors.primaryContainer,
    blob: Color(0x1AFFFFFF),
  );
}

class GuideCardData {
  const GuideCardData({
    required this.icon,
    required this.title,
    required this.description,
    required this.caption,
    required this.actionLabel,
    required this.style,
    required this.onAction,
    this.actionIcon,
  });

  final IconData icon;
  final String title;
  final String description;
  final String caption;
  final String actionLabel;
  final IconData? actionIcon;
  final GuideStyle style;
  final VoidCallback onAction;
}

class GuideCard extends StatelessWidget {
  const GuideCard({super.key, required this.data});

  final GuideCardData data;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final s = data.style;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: s.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.elevated,
      ),
      child: Stack(
        children: [
          Positioned(right: -16, bottom: -24, child: GlowBlob(size: 120, color: s.blob, blur: 24)),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: data.onAction,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(data.icon, size: 22, color: s.iconColor),
                    const SizedBox(height: 8),
                    Text(data.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium!.copyWith(color: s.titleColor, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(data.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium!.copyWith(color: s.bodyColor)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            child: Text(data.caption,
                                overflow: TextOverflow.ellipsis,
                                style: text.labelSmall!.copyWith(color: s.captionColor))),
                        const SizedBox(width: 8),
                        Material(
                          color: s.buttonBackground,
                          shape: const StadiumBorder(),
                          child: InkWell(
                            customBorder: const StadiumBorder(),
                            onTap: data.onAction,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (data.actionIcon != null) ...[
                                    Icon(data.actionIcon, size: 14, color: s.buttonForeground),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(data.actionLabel,
                                      style: text.labelMedium!.copyWith(color: s.buttonForeground)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
