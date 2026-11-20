import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../controllers/store_controller.dart';
import '../../core/extensions/context_x.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/utils/external_launcher.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/store.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_popups.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../shared/widgets/surface_card.dart';
import 'store_detail_sheet.dart';

/// Frame Figma "Explore": peta + pencarian + daftar toko terdekat.
/// Peta memakai OpenStreetMap (flutter_map), tanpa API key.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _search = TextEditingController();
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = context.read<StoreController>();
      if (c.location == null) c.load();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _focusStore(FruitStore s) {
    context.read<StoreController>().select(s.id);
    _mapController.move(LatLng(s.lat, s.lng), 15);
  }

  Future<void> _openFilters() async {
    final c = context.read<StoreController>();
    await showAppSheet<void>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final text = ctx.textTheme;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Filter stores', style: text.titleLarge),
              const SizedBox(height: 16),
              Text('Radius', style: text.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final r in StoreController.radiusOptions)
                    ChoiceChip(
                      label: Text('${r.toStringAsFixed(0)} km'),
                      selected: c.radiusKm == r,
                      selectedColor: AppColors.primaryContainer,
                      onSelected: (_) {
                        c.setRadius(r);
                        setSheet(() {});
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Open now only', style: text.labelLarge),
                value: c.onlyOpen,
                onChanged: (v) {
                  c.setOnlyOpen(v);
                  setSheet(() {});
                },
              ),
              const SizedBox(height: 8),
              Text('Sort by', style: text.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<StoreSort>(
                segments: const [
                  ButtonSegment(value: StoreSort.distance, label: Text('Distance')),
                  ButtonSegment(value: StoreSort.name, label: Text('Name')),
                ],
                selected: {c.sort},
                onSelectionChanged: (s) {
                  c.setSort(s.first);
                  setSheet(() {});
                },
              ),
              const SizedBox(height: 20),
              AppButton(label: 'Done', onPressed: () => Navigator.of(ctx).pop()),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<StoreController>();
    final text = context.textTheme;
    final list = c.visible;
    final loc = c.location;
    final center = loc == null ? const LatLng(-6.2440, 106.7990) : LatLng(loc.lat, loc.lng);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.only(left: 14, right: 6),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), boxShadow: AppShadows.card),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 20, color: AppColors.onSurface),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _search,
                          onChanged: c.setQuery,
                          style: text.bodyLarge!.copyWith(color: AppColors.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Search fruit stores or supermarkets...',
                            hintStyle: text.bodyLarge!.copyWith(color: AppColors.outline, fontSize: 13),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_search.text.isNotEmpty)
                        InkResponse(
                          onTap: () {
                            _search.clear();
                            c.setQuery('');
                          },
                          child: const Icon(Icons.close_rounded, size: 18, color: AppColors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkResponse(
                onTap: _openFilters,
                radius: 22,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), boxShadow: AppShadows.card),
                  child: const Icon(Icons.tune_rounded, size: 20, color: AppColors.onSurface),
                ),
              ),
            ],
          ),
        ),
        // Peta (tinggi tetap, tidak ikut scroll daftar)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(initialCenter: center, initialZoom: 14),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.buahaya.app',
                      ),
                      MarkerLayer(markers: [
                        if (loc != null)
                          Marker(
                            point: center,
                            width: 28,
                            height: 28,
                            child: const _YouMarker(),
                          ),
                        for (final s in list)
                          Marker(
                            point: LatLng(s.lat, s.lng),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => _focusStore(s),
                              child: Icon(Icons.location_on_rounded,
                                  size: 36,
                                  color: c.selectedId == s.id ? AppColors.amber : AppColors.primary),
                            ),
                          ),
                      ]),
                    ],
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Material(
                      color: const Color(0xE6FFFFFF),
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => c.setRadius(c.radiusKm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.adjust_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('Radius: ${c.radiusKm.toStringAsFixed(0)} km',
                                style: text.labelSmall!.copyWith(color: AppColors.onSurface)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Material(
                      color: const Color(0xE6FFFFFF),
                      shape: const CircleBorder(),
                      child: InkResponse(
                        customBorder: const CircleBorder(),
                        onTap: () => loc == null
                            ? c.load()
                            : _mapController.move(LatLng(loc.lat, loc.lng), 14),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.my_location_rounded, size: 18, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: PillBadge(
                      label: '${list.length} stores checked by Buahaya AI',
                      icon: Icons.verified_outlined,
                      backgroundColor: const Color(0xE6FFFFFF),
                      foregroundColor: AppColors.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: c.loading && list.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Nearby fruit stores', style: text.titleMedium),
                        ),
                        const PillBadge(
                          label: 'Kebayoran Baru',
                          backgroundColor: AppColors.secondaryContainer,
                          foregroundColor: AppColors.primary,
                          icon: Icons.place_outlined,
                          iconSize: 12,
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (list.isEmpty)
                      SurfaceCard(child: Text('No stores match your filters.', style: text.bodyLarge)),
                    for (final s in list)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _StoreRow(store: s, onFocus: () => _focusStore(s)),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

}

class _YouMarker extends StatelessWidget {
  const _YouMarker();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0x4D3B82F6),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x663B82F6), width: 6),
        ),
        child: Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.onPrimary, width: 2),
            ),
          ),
        ),
      );
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({required this.store, required this.onFocus});

  final FruitStore store;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;
    final open = store.isOpenAt(DateTime.now());
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      onTap: () => showStoreDetailSheet(context, store),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StoreImage(store: store, size: 72),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(store.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text('${formatDistance(store.distanceKm)} • Open ${store.hoursLabel}', style: text.bodyMedium),
                    const SizedBox(height: 6),
                    OpenBadge(open: open),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Map & directions',
                  kind: AppButtonKind.tonal,
                  icon: Icons.directions_outlined,
                  height: 40,
                  textStyle: text.labelMedium,
                  onPressed: () => openDirections(context, lat: store.lat, lng: store.lng, label: store.name),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'View details',
                  trailingIcon: Icons.arrow_forward_rounded,
                  height: 40,
                  textStyle: text.labelMedium,
                  onPressed: () => showStoreDetailSheet(context, store),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

