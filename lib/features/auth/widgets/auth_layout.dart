import 'package:flutter/material.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/brand_mark.dart';
import '../../../shared/widgets/glow_blob.dart';

/// Latar hijau + blob blur + logo/judul, dipakai Login, Sign up, dan Reset password.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.child, this.footer});

  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
              top: -60, right: -60, child: GlowBlob(size: 220, color: Color(0x40ACF2CB), blur: 40)),
          const Positioned(
              top: 120, left: -60, child: GlowBlob(size: 170, color: Color(0x4DCDE9DD), blur: 24)),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    child: Column(
                      children: [
                        const BrandMark(size: 80),
                        const SizedBox(height: 12),
                        Text('Buahaya', style: text.headlineLarge),
                        const SizedBox(height: 4),
                        Text('Pick the right fruit, Avoid the BUAHAYA!',
                            textAlign: TextAlign.center, style: text.bodyLarge),
                        const SizedBox(height: 24),
                        child,
                      ],
                    ),
                  ),
                ),
                if (footer != null)
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: footer),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Teks error kecil merah.
class FieldHint extends StatelessWidget {
  const FieldHint(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: context.textTheme.labelSmall!.copyWith(color: AppColors.error, fontWeight: FontWeight.w500));
}
