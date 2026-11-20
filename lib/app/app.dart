import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../domain/repositories/fruit_scan_repository.dart';
import 'dependencies.dart';

class BuahayaApp extends StatefulWidget {
  const BuahayaApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<BuahayaApp> createState() => _BuahayaAppState();
}

class _BuahayaAppState extends State<BuahayaApp> {
  late final GoRouter _router = createRouter(widget.deps.auth);
  AuthStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    widget.deps.auth.addListener(_onAuthChanged);
    widget.deps.auth.restoreSession();
  }

  /// Muat / bersihkan data saat status sesi berubah.
  void _onAuthChanged() {
    final d = widget.deps;
    if (d.auth.status == _lastStatus) return;
    _lastStatus = d.auth.status;
    if (d.auth.isAuthenticated) {
      d.profile.load();
      d.shopping.load();
      d.notifications.load();
      d.stores.load();
    } else if (d.auth.status == AuthStatus.unauthenticated) {
      d.profile.reset();
      d.shopping.reset();
      d.notifications.reset();
    }
  }

  @override
  void dispose() {
    widget.deps.auth.removeListener(_onAuthChanged);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.deps;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: d.auth),
        ChangeNotifierProvider.value(value: d.profile),
        ChangeNotifierProvider.value(value: d.shopping),
        ChangeNotifierProvider.value(value: d.notifications),
        ChangeNotifierProvider.value(value: d.stores),
        Provider<FruitScanRepository>.value(value: d.scanRepository),
      ],
      child: MaterialApp.router(
        title: 'Buahaya',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
        // Semua layar memakai lebar yang sama (maks. 480) agar konsisten di semua ukuran Android.
        builder: (context, child) => ColoredBox(
          color: AppColors.background,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
