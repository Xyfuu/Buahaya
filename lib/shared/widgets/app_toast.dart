import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

abstract final class AppToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String title,
    String? message,
    bool error = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    dismiss();
    final entry = OverlayEntry(
      builder: (ctx) => _ToastView(title: title, message: message, error: error),
    );
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(duration, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({required this.title, this.message, this.error = false});

  final String title;
  final String? message;
  final bool error;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 220))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24 + bottom,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _c,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: widget.error ? AppColors.error : AppColors.toastBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.elevated,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: widget.error ? AppColors.errorContainer : AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(widget.error ? Icons.priority_high_rounded : Icons.check_rounded,
                              size: 18,
                              color: widget.error ? AppColors.onErrorContainer : AppColors.primaryDark),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(widget.title,
                                  style: text.labelMedium!.copyWith(
                                      color: AppColors.onPrimary, fontWeight: FontWeight.w700)),
                              if (widget.message != null)
                                Text(widget.message!,
                                    style: text.bodySmall!.copyWith(color: AppColors.toastBody)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
