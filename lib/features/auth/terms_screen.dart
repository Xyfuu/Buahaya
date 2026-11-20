import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_x.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/sub_screen_header.dart';
import 'terms_content.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key, this.readOnly = false});

    final bool readOnly;

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final _scroll = ScrollController();
  bool _atBottom = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final atBottom = _scroll.position.pixels >= _scroll.position.maxScrollExtent - 24;
    if (atBottom != _atBottom) setState(() => _atBottom = atBottom);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _skipToBottom() => _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final body = text.bodyLarge!.copyWith(fontSize: 15, height: 1.6, color: AppColors.onSurface);

    Widget block(TermsBlock b) => switch (b) {
          TermsPara(:final text) => Padding(
              padding: const EdgeInsets.only(bottom: 14), child: Text(text, style: body)),
          TermsBullet(:final text, :final lead) => Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10),
                    child: Container(
                        width: 5, height: 5,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  ),
                  Expanded(
                    child: Text.rich(TextSpan(style: body, children: [
                      if (lead != null) TextSpan(text: lead, style: body.copyWith(fontWeight: FontWeight.w700)),
                      TextSpan(text: text),
                    ])),
                  ),
                ],
              ),
            ),
        };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenHeader(
              title: 'Terms & Conditions',
              leftAligned: true,
              circleBack: false,
              onBack: () => context.pop(widget.readOnly ? null : false),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(TermsContent.title, style: text.headlineMedium),
                    const SizedBox(height: 4),
                    Text(TermsContent.lastUpdated,
                        style: text.labelMedium!.copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 20),
                    for (final b in TermsContent.intro) block(b),
                    for (final s in TermsContent.sections) ...[
                      const Divider(height: 32),
                      Text(s.title, style: text.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      for (final b in s.blocks) block(b),
                    ],
                    const SizedBox(height: 24),
                    if (!widget.readOnly) ...[
                      AppButton(label: 'Accept & Continue', onPressed: () => context.pop(true)),
                      const SizedBox(height: 8),
                      AppButton(
                        label: 'Decline & Go Back',
                        kind: AppButtonKind.ghost,
                        onPressed: () => context.pop(false),
                      ),
                    ],
                  ],
                ),
              ),
            ),
                        Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.hairline)),
              ),
              child: AppButton(
                label: 'Skip to bottom',
                kind: AppButtonKind.tonal,
                icon: Icons.keyboard_double_arrow_down_rounded,
                height: 44,
                onPressed: _atBottom ? null : _skipToBottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
