import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import 'widgets/reset_link_sheet.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final animation = ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;
    final slide = animation.drive(
      Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic)),
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => context.pop(false)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: slide,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 20 + media.padding.bottom),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: AppShadows.sheet,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 6,
                        decoration:
                            BoxDecoration(color: AppColors.handle, borderRadius: BorderRadius.circular(999)),
                      ),
                      const SizedBox(height: 16),
                      ResetLinkSheetContent(
                        title: 'Reset password',
                        subtitle: 'Get back into your Buahaya account',
                        description: 'We’ll send you a link to reset your password.',
                        buttonLabel: 'Send reset link',
                        onClose: (sent) => context.pop(sent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
