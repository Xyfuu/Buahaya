import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../features/notifications/invite_popup.dart';
import '../shared/widgets/app_bottom_nav.dart';
import '../shared/widgets/app_header.dart';

/// Kerangka tab utama: header & bottom nav TETAP, hanya isi tengah yang scroll.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _titles = ['Home', 'Shopping List', 'Explore', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(AppHeader.contentHeight + top),
        child: AppHeader(
          subtitle: _titles[shell.currentIndex],
          onBell: () => showInvitePopup(context),
          onAvatar: () => shell.goBranch(3, initialLocation: shell.currentIndex == 3),
        ),
      ),
      body: shell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: shell.currentIndex,
        onTab: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        onScan: () => context.push(AppRoutes.scan),
      ),
    );
  }
}
