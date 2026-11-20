import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/shopping_controller.dart';
import '../../core/config/app_config.dart';
import '../../core/extensions/context_x.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/scan.dart';
import '../../domain/repositories/fruit_scan_repository.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_popups.dart';
import '../../shared/widgets/app_toast.dart';
import '../../shared/widgets/sub_screen_header.dart';
import 'scan_camera.dart';
import 'widgets/scan_widgets.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  final ScanCamera _cam = ScanCamera();
  late final FruitScanRepository _repo = context.read<FruitScanRepository>();

  LiveDetection? _live;
  ScanResult? _lastResult;
  bool _expanded = false;
  bool _capturing = false;
  bool _sheetOpen = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cam.addListener(() {
      if (mounted) setState(() {});
    });
    _startCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAskCreateList());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fallbackTimer?.cancel();
    _cam.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _fallbackTimer?.cancel();
      _cam.disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _startCamera();
    }
  }

    Future<void> _startCamera() async {
    await _cam.initialize();
    if (!mounted) return;
    _startLive();
  }

  void _startLive() {
    _fallbackTimer?.cancel();
    if (_cam.isReady) {
            _cam.startLiveStream((frame) async {
        try {
          final r = await _repo.detectLive(frame);
          if (mounted) setState(() => _live = r);
        } catch (_) {}
      });
    } else if (AppConfig.useMockData) {
            _fallbackTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
        final r = await _repo.detectLive(const ScanFrame(width: 0, height: 0, planes: [], rowStrides: []));
        if (mounted) setState(() => _live = r);
      });
    }
  }

  Future<void> _maybeAskCreateList() async {
    if (!mounted || context.read<ShoppingController>().hasActive) return;
    await showPopup<void>(
      context,
      dismissible: false,
      builder: (ctx) => PopupCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_outline_rounded, size: 34, color: AppColors.primary),
                ),
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(color: AppColors.amber, shape: BoxShape.circle),
                    child: const Icon(Icons.priority_high_rounded, size: 15, color: AppColors.onPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Create a new\nshopping list?', textAlign: TextAlign.center, style: ctx.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('You have no active shopping list.\nYour scanned fruit will be added to In Cart',
                textAlign: TextAlign.center, style: ctx.textTheme.bodyLarge),
            const SizedBox(height: 20),
            AppButton(
              label: 'Yes, create a list',
              icon: Icons.add_circle_outline_rounded,
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push(AppRoutes.createList);
              },
            ),
            const SizedBox(height: 8),
            AppButton(label: 'No, back to scan', kind: AppButtonKind.tonal, onPressed: () => Navigator.of(ctx).pop()),
          ],
        ),
      ),
    );
  }

  void _close() => context.canPop() ? context.pop() : context.go(AppRoutes.home);

    Future<void> _capture() async {
    if (_capturing) return;
    setState(() => _capturing = true);
    try {
      String? path;
      if (_cam.isReady) {
        path = await _cam.capture();
        if (path == null && mounted) {
          AppToast.show(context, title: 'Could not take photo', message: 'Please try again.', error: true);
          return;
        }
      } else if (!AppConfig.useMockData) {
        AppToast.show(context, title: 'Camera unavailable', message: 'Allow camera access to scan.', error: true);
        return;
      }
      final result = await _repo.analyzePhoto(path ?? '');
      if (!mounted) return;
      _lastResult = result;
      await _openConfirm(result);
    } catch (_) {
      if (mounted) {
        AppToast.show(context, title: 'Scan failed', message: 'Please try again.', error: true);
      }
    } finally {
      if (mounted) {
        setState(() => _capturing = false);
        if (_cam.isReady) _startLive();
      }
    }
  }

  Future<void> _confirmFromLive() async {
    final live = _live;
    if (live == null || live.detections.isEmpty) return;
    await _openConfirm(_lastResult ?? ScanResult(live.detections));
  }

  Future<void> _openConfirm(ScanResult result) async {
    if (_sheetOpen || result.primary == null) return;
    _sheetOpen = true;
    final confirmed = await showAppSheet<bool>(
      context,
      builder: (ctx) => ConfirmScanSheet(result: result),
    );
    _sheetOpen = false;
    if (!mounted) return;
    if (confirmed == true) {
      _lastResult = null;
      setState(() => _expanded = context.read<ShoppingController>().hasActive);
    }
  }

    @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final list = context.watch<ShoppingController>().active;
    final p = _live?.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SubScreenHeader(
              title: 'Fruit Scan',
              onBack: _close,
              titleStyle: text.titleMedium!.copyWith(fontWeight: FontWeight.w700, color: AppColors.deepGreen),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    color: AppColors.cameraBackground,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreviewSlot(camera: _cam, onRetry: _startCamera),
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Flexible(child: LiveDetectorChip(detection: _live)),
                                  const Spacer(),
                                  RoundOverlayButton(
                                    icon: _cam.torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                    active: _cam.torchOn,
                                    tooltip: 'Flash',
                                    onTap: _cam.toggleTorch,
                                  ),
                                ],
                              ),
                              if (list != null) ...[
                                const SizedBox(height: 10),
                                ScanListDropdown(
                                  list: list,
                                  expanded: _expanded,
                                  onToggle: () => setState(() => _expanded = !_expanded),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 18,
                          child: Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: ZoomPill(zoom: _cam.zoom, onChanged: _cam.setZoomStep),
                                ),
                              ),
                              ShutterButton(onTap: _capture, busy: _capturing),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: RoundOverlayButton(
                                    icon: _cam.locked ? Icons.lock_rounded : Icons.lock_open_rounded,
                                    active: _cam.locked,
                                    tooltip: 'Lock focus & exposure',
                                    onTap: _cam.toggleLock,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
                        Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.verified_outlined, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p == null ? 'No fruit detected' : '${p.fresh} Fresh ${p.fruit.name}${p.fresh == 1 ? '' : 's'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                  ),
                  AppButton(
                    label: 'Confirm',
                    icon: Icons.shopping_basket_outlined,
                    expand: false,
                    height: 40,
                    textStyle: text.labelMedium,
                    onPressed: (p == null || p.fresh == 0) ? null : _confirmFromLive,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmScanSheet extends StatelessWidget {
  const ConfirmScanSheet({super.key, required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final shopping = context.read<ShoppingController>();
    final d = result.primary!;
    final plural = d.fresh == 1 ? '' : 's';
    final name = d.fruit.name.toLowerCase();

    final item = shopping.active?.itemFor(d.fruit.id);
    final inPlan = item != null && item.planned > 0;
    final needed = inPlan ? item.remaining : 0;
    final add = inPlan ? math.min(d.fresh, needed) : d.fresh;
    final extra = d.fresh - add;
    final perfect = inPlan && add == needed;

    Widget tile(String label, String value, String caption, {Color? bg, Color? valueColor}) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(color: bg ?? AppColors.surface, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Text(label, style: text.bodySmall!.copyWith(fontSize: 10, color: AppColors.secondaryDark)),
                Text(value, style: text.titleMedium!.copyWith(color: valueColor ?? AppColors.primary, fontWeight: FontWeight.w700)),
                Text(caption, style: text.bodySmall!.copyWith(fontSize: 9, color: valueColor ?? AppColors.outline)),
              ],
            ),
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Confirm fresh fruit', style: text.titleLarge)),
            InkResponse(
              onTap: () => Navigator.of(context).pop(false),
              radius: 20,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 18, color: AppColors.onPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('${d.fresh} fresh $name$plural found', style: text.labelLarge!.copyWith(fontWeight: FontWeight.w700, color: AppColors.onSurface))),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            tile('Needed', inPlan ? '$needed' : '–', inPlan ? 'To pick' : 'Not in list', valueColor: AppColors.amberDark),
            const SizedBox(width: 8),
            tile('Scanned', '${d.fresh}', extra > 0 ? '+$extra extra' : 'Matched'),
            const SizedBox(width: 8),
            tile('Add to cart', '$add', perfect ? 'Just right ✓' : (inPlan ? 'Partial' : 'Extra'), bg: AppColors.primaryContainer),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.secondaryDark),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                extra > 0
                    ? '$add $name${add == 1 ? '' : 's'} will move to In cart, the other $extra $name${extra == 1 ? '' : 's'} will be skipped'
                    : '$add $name${add == 1 ? '' : 's'} will move to In cart',
                style: text.bodySmall!.copyWith(color: AppColors.secondaryDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Confirm (Add $add to cart)',
          icon: Icons.check_circle_outline_rounded,
          onPressed: add == 0
              ? null
              : () async {
                  await shopping.addScanned(d.fruit, add);
                  if (!context.mounted) return;
                  AppToast.show(context,
                      title: 'Added to cart', message: '$add ${d.fruit.name}${add == 1 ? '' : 's'} added.');
                  Navigator.of(context).pop(true);
                },
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Scan again',
          icon: Icons.photo_camera_outlined,
          kind: AppButtonKind.tonal,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
