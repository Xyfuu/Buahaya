import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_assets.dart';
import '../../../shared/widgets/app_image.dart';

import '../../../core/extensions/context_x.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/models/shopping.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_popups.dart';
import '../../../shared/widgets/app_toast.dart';

/// Sheet "Create a fruit haul": preview kartu + toggle isi + tombol unduh.
Future<void> showHaulPreviewSheet(BuildContext context, ShoppingTrip trip) {
  return showAppSheet<void>(
    context,
    builder: (_) => _HaulPreview(trip: trip),
  );
}

class _HaulPreview extends StatefulWidget {
  const _HaulPreview({required this.trip});
  final ShoppingTrip trip;

  @override
  State<_HaulPreview> createState() => _HaulPreviewState();
}

class _HaulPreviewState extends State<_HaulPreview> {
  bool _fruitList = true;
  bool _duration = true;
  bool _date = true;

  /// Foto latar pilihan pengguna (kamera/galeri). Null = pakai template default.
  String? _bgPath;

  Future<void> _changeBackground() async {
    final picked = await showAppSheet<XFile?>(
      context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Change background photo',
              style: ctx.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          AppButton(
            label: 'Take photo',
            icon: Icons.photo_camera_outlined,
            onPressed: () async {
              final f = await ImagePicker().pickImage(
                  source: ImageSource.camera, imageQuality: 85, maxWidth: 1200);
              if (ctx.mounted) Navigator.of(ctx).pop(f);
            },
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Choose from photo library',
            icon: Icons.photo_library_outlined,
            kind: AppButtonKind.tonal,
            onPressed: () async {
              final f = await ImagePicker().pickImage(
                  source: ImageSource.gallery, imageQuality: 85, maxWidth: 1200);
              if (ctx.mounted) Navigator.of(ctx).pop(f);
            },
          ),
        ],
      ),
    );
    if (picked != null && mounted) setState(() => _bgPath = picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final t = widget.trip;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            InkResponse(
              onTap: () => Navigator.of(context).pop(),
              radius: 20,
              child: const Icon(Icons.arrow_back_rounded, size: 20),
            ),
            Expanded(
              child: Column(
                children: [
                  Text('Create a fruit haul', style: text.titleLarge),
                  Text('${t.name} • Trip finished', style: text.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: _HaulCard(
            trip: t,
            showList: _fruitList,
            showDuration: _duration,
            showDate: _date,
            backgroundPath: _bgPath,
          ),
        ),
        const SizedBox(height: 10),
        _BackgroundRow(custom: _bgPath != null, onChange: _changeBackground),
        const SizedBox(height: 16),
        _ToggleRow(icon: Icons.format_list_bulleted_rounded, label: 'Fruit list', value: _fruitList,
            onChanged: (v) => setState(() => _fruitList = v)),
        _ToggleRow(icon: Icons.schedule_rounded, label: 'Duration', value: _duration,
            onChanged: (v) => setState(() => _duration = v)),
        _ToggleRow(icon: Icons.event_outlined, label: 'Date', value: _date,
            onChanged: (v) => setState(() => _date = v)),
        const SizedBox(height: 14),
        AppButton(
          label: 'Download image',
          icon: Icons.download_rounded,
          onPressed: () {
            AppToast.show(context,
                title: 'Image saved', message: 'Your fruit haul is ready to share.');
          },
        ),
        const SizedBox(height: 6),
        Text('Share to your Instagram Story', textAlign: TextAlign.center, style: text.bodySmall),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.icon, required this.label, required this.value, required this.onChanged});

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: context.textTheme.bodyLarge!.copyWith(color: AppColors.onSurface))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _HaulCard extends StatelessWidget {
  const _HaulCard({
    required this.trip,
    required this.showList,
    required this.showDuration,
    required this.showDate,
    this.backgroundPath,
  });

  final ShoppingTrip trip;
  final bool showList;
  final bool showDuration;
  final bool showDate;
  final String? backgroundPath;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 220,
        height: 300,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Lapisan 1: foto latar, atau gradasi jika foto belum ada
            AppImage(
              source: backgroundPath ?? AppAssets.haulBackground,
              fallback: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B6B4F), Color(0xFF175E41), Color(0xFF0E3B29)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Lapisan 2: gelap di bawah agar teks terbaca
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x59000000), Color(0xCC000000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Lapisan 3: teks dan chip
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('FRUIT HAUL',
                        style: text.labelSmall!.copyWith(color: AppColors.onPrimary, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 14),
                  Text('Fresh fruit trip',
                      style: text.titleMedium!
                          .copyWith(color: AppColors.onPrimary, fontWeight: FontWeight.w800)),
                  if (showDate)
                    Text(formatDate(trip.finishedAt),
                        style: text.labelMedium!
                            .copyWith(color: AppColors.amberAccent, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    children: [
                      _Chip('${trip.fruitTypes} types • ${trip.totalFruits} fruits'),
                      if (showDuration) _Chip(formatDuration(trip.duration)),
                    ],
                  ),
                  if (showList) ...[
                    const SizedBox(height: 10),
                    Text(
                      trip.fruits.map((f) => '${f.fruit.name} ×${f.count}').join('  •  '),
                      textAlign: TextAlign.center,
                      style: text.bodyMedium!.copyWith(color: AppColors.mint),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundRow extends StatelessWidget {
  const _BackgroundRow({required this.custom, required this.onChange});

  final bool custom;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    return Row(
      children: [
        const Icon(Icons.image_outlined, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            custom ? 'Background photo (custom)' : 'Background photo',
            style: text.bodyLarge!.copyWith(color: AppColors.onSurface),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onChange,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.photo_camera_back_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('Change photo',
                    style: text.labelSmall!.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: context.textTheme.labelSmall!.copyWith(color: AppColors.onPrimary)),
      );
}
