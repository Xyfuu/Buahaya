import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../domain/models/scan.dart';
import '../../../domain/models/shopping.dart';
import '../scan_camera.dart';

/// Area preview kamera (siap diganti/dikembangkan). Bila kamera tidak tersedia,
/// menampilkan placeholder gelap + pesan + tombol coba lagi.
class CameraPreviewSlot extends StatelessWidget {
  const CameraPreviewSlot({super.key, required this.camera, required this.onRetry});

  final ScanCamera camera;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final c = camera.controller;
    if (camera.isReady && c != null && c.value.isInitialized) {
      final size = c.value.previewSize;
      return ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size?.height ?? 1080,
            height: size?.width ?? 1920,
            child: CameraPreview(c),
          ),
        ),
      );
    }
    final message = switch (camera.status) {
      CameraStatus.initializing => 'Starting camera…',
      CameraStatus.denied => 'Camera permission is needed to scan fruit.',
      _ => 'Camera is not available on this device.',
    };
    return Container(
      color: AppColors.cameraBackground,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (camera.status == CameraStatus.initializing)
            const SizedBox(
                width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryContainer))
          else ...[
            const Icon(Icons.no_photography_outlined, size: 36, color: AppColors.primaryContainer),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: text.bodyLarge!.copyWith(color: AppColors.toastBody)),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryContainer, size: 18),
              label: Text('Try again', style: text.labelMedium!.copyWith(color: AppColors.primaryContainer)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Chip "● Live AI Detector: 4 Apples Detected".
class LiveDetectorChip extends StatelessWidget {
  const LiveDetectorChip({super.key, required this.detection});

  final LiveDetection? detection;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final p = detection?.primary;
    final label = p == null ? 'Looking for fruit…' : '${p.total} ${p.fruit.name}${p.total == 1 ? '' : 's'} Detected';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xE6FFFFFF), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(
              TextSpan(style: text.labelMedium!.copyWith(color: AppColors.onSurface), children: [
                const TextSpan(text: 'Live AI Detector: '),
                TextSpan(text: label, style: const TextStyle(color: AppColors.primary)),
              ]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class RoundOverlayButton extends StatelessWidget {
  const RoundOverlayButton({super.key, required this.icon, required this.onTap, this.active = false, this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkResponse(
        onTap: onTap,
        radius: 26,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: active ? AppColors.primaryContainer : const Color(0xE6E6E6E6), shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: active ? AppColors.primaryDark : AppColors.onSurface),
        ),
      ),
    );
  }
}

/// Kartu "Shopping List" (collapsed/expanded) di atas kamera.
class ScanListDropdown extends StatelessWidget {
  const ScanListDropdown({super.key, required this.list, required this.expanded, required this.onToggle});

  final ShoppingList list;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final items = list.planItems;
    final summary = items.map((i) => '${i.fruit.name} (${i.inCart}/${i.planned})').join(', ');
    return Material(
      color: const Color(0xEBFFFFFF),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: expanded ? 28 : 24,
                      height: expanded ? 28 : 24,
                      decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
                      child: Icon(Icons.check_rounded, size: expanded ? 18 : 15, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: expanded
                          ? Text('Shopping List',
                              style: text.titleLarge!.copyWith(color: AppColors.secondaryDark))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Shopping List ',
                                    style: text.labelSmall!.copyWith(color: AppColors.secondaryDark)),
                                Text(summary.isEmpty ? 'No items' : summary,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.labelMedium!.copyWith(
                                        color: AppColors.onSurface, fontWeight: FontWeight.w700)),
                              ],
                            ),
                    ),
                    Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.onSurfaceVariant),
                  ],
                ),
                if (expanded) ...[
                  const SizedBox(height: 12),
                  for (final i in items) _ProgressRow(item: i),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 6),
                      const Icon(Icons.hourglass_bottom_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('${list.totalRemaining} fruits remaining',
                          style: text.labelMedium!.copyWith(color: AppColors.onSurface)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.item});

  final ShoppingItem item;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final done = item.inCart > 0;
    final progress = item.planned == 0 ? 0.0 : (item.inCart / item.planned).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: done ? AppColors.surfaceContainer : AppColors.surface, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(child: Text(item.fruit.name, style: text.labelLarge!.copyWith(letterSpacing: 0))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.inCart}/${item.planned} pieces',
                  style: text.labelMedium!
                      .copyWith(color: done ? AppColors.primary : AppColors.secondaryDark, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  width: 64,
                  height: 4,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.handle,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pil zoom "1x | 2x".
class ZoomPill extends StatelessWidget {
  const ZoomPill({super.key, required this.zoom, required this.onChanged});

  final double zoom;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget seg(double v, String label) {
      final on = (zoom - v).abs() < 0.5;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 34,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: on ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(99)),
          child: Text(label,
              style: context.textTheme.labelSmall!.copyWith(color: on ? AppColors.onPrimary : AppColors.onSurface)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: const Color(0xE6E6E6E6), borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [seg(1, '1x'), seg(2, '2x')]),
    );
  }
}

/// Tombol shutter besar.
class ShutterButton extends StatelessWidget {
  const ShutterButton({super.key, required this.onTap, required this.busy});

  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x33FFFFFF),
          border: Border.all(color: AppColors.onPrimary, width: 4),
          boxShadow: AppShadows.elevated,
        ),
        child: Container(
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: busy
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onPrimary))
              : const Icon(Icons.photo_camera_outlined, size: 28, color: AppColors.onPrimary),
        ),
      ),
    );
  }
}
