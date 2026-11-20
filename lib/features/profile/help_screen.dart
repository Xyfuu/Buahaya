import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/app_config.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/sub_screen_header.dart';
import '../../shared/widgets/surface_card.dart';

/// Help & Privacy: FAQ, link ke Terms, dan kontak support.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    ('How accurate is the freshness check?',
        'The AI estimates freshness from visual cues only. It cannot detect internal decay or contamination, so always inspect your fruit.'),
    ('How do I scan fruit?',
        'Open Scan fruit from the bottom bar, point the camera at your fruit, then tap the shutter. Confirm the results to add them to your cart.'),
    ('Can I shop with my family?',
        'Yes. Invite a username or email from your active list. Invited members can check off items in real time.'),
    ('Why can I only have one active list?',
        'Keeping one active trip at a time avoids mixing up cart items. Finish the current list to start a new one.'),
  ];

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenHeader(title: 'Help & Privacy', onBack: () => context.pop(), leftAligned: true, circleBack: false),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                children: [
                  Text('FAQs', style: text.titleMedium),
                  const SizedBox(height: 8),
                  for (final f in _faqs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SurfaceCard(
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: const EdgeInsets.only(bottom: 8),
                            title: Text(f.$1, style: text.labelLarge!.copyWith(letterSpacing: 0)),
                            children: [Align(alignment: Alignment.centerLeft, child: Text(f.$2, style: text.bodyLarge))],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SurfaceCard(
                    onTap: () => context.push('${AppRoutes.terms}?view=1'),
                    child: Row(children: [
                      const Icon(Icons.description_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Terms of Service & Privacy Policy', style: text.labelLarge!.copyWith(letterSpacing: 0))),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  SurfaceCard(
                    onTap: () => launchUrl(Uri.parse('mailto:${AppConfig.supportEmail}')),
                    child: Row(children: [
                      const Icon(Icons.mail_outline_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Contact support', style: text.labelLarge!.copyWith(letterSpacing: 0))),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Center(child: Text('Buahaya ${AppConfig.version}', style: text.labelSmall)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
