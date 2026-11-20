import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

/// Popup di tengah/atas layar dengan latar blur + scrim.
/// Halaman di belakangnya tidak bisa di-scroll (route modal menyerap sentuhan).
Future<T?> showPopup<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
  Alignment alignment = Alignment.center,
  EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
  double maxWidth = 340,
}) {
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierLabel: 'Close',
    barrierColor: AppColors.scrim,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, _, __) {
      return Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: dismissible ? () => Navigator.of(ctx).pop() : null,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: alignment,
              child: Padding(
                padding: margin,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Material(type: MaterialType.transparency, child: builder(ctx)),
                ),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

/// Kartu putih rounded 28 untuk isi popup.
class PopupCard extends StatelessWidget {
  const PopupCard({super.key, required this.child, this.padding = const EdgeInsets.all(24)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.sheet,
      ),
      child: child,
    );
  }
}

/// Popup konfirmasi: ikon bulat + judul + pesan + aksi.
class ConfirmPopup extends StatelessWidget {
  const ConfirmPopup({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actions,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.surfaceContainer,
    this.extra,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<Widget> actions;
  final Color iconColor;
  final Color iconBackground;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return PopupCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
            child: Icon(icon, size: 26, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: text.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: text.bodyLarge),
          if (extra != null) ...[const SizedBox(height: 16), extra!],
          const SizedBox(height: 20),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            actions[i],
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet modal. Isi tidak di-scroll; naik mengikuti keyboard.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
  double? heightFactor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: dismissible,
    enableDrag: dismissible,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    builder: (ctx) => AppSheet(heightFactor: heightFactor, child: builder(ctx)),
  );
}

class AppSheet extends StatelessWidget {
  const AppSheet({super.key, required this.child, this.heightFactor});

  final Widget child;
  final double? heightFactor;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final content = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 12, 24, 20 + media.padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: AppShadows.sheet,
      ),
      child: Column(
        mainAxisSize: heightFactor == null ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(color: AppColors.handle, borderRadius: BorderRadius.circular(999)),
          ),
          const SizedBox(height: 16),
          if (heightFactor == null) child else Expanded(child: child),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 480,
            maxHeight: heightFactor == null
                ? double.infinity
                : (media.size.height - media.viewInsets.bottom) * heightFactor!,
          ),
          child: heightFactor == null
              ? content
              : SizedBox(height: (media.size.height - media.viewInsets.bottom) * heightFactor!, child: content),
        ),
      ),
    );
  }
}
