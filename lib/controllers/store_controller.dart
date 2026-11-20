import 'package:flutter/foundation.dart';

import '../domain/models/store.dart';
import '../domain/repositories/store_repository.dart';

enum StoreSort { distance, name }

class StoreController extends ChangeNotifier {
  StoreController(this._repo);

  final StoreRepository _repo;

  static const radiusOptions = [1.0, 3.0, 5.0, 10.0];

  List<FruitStore> _all = const [];
  GeoPoint? location;
  String area = '';
  double radiusKm = 3;
  String query = '';
  bool onlyOpen = false;
  StoreSort sort = StoreSort.distance;
  String? selectedId;
  bool loading = false;

  List<FruitStore> get visible {
    final q = query.trim().toLowerCase();
    final now = DateTime.now();
    final list = _all.where((s) {
      if (q.isNotEmpty && !s.name.toLowerCase().contains(q)) return false;
      if (onlyOpen && !s.isOpenAt(now)) return false;
      return true;
    }).toList();
    list.sort(sort == StoreSort.distance
        ? (a, b) => a.distanceKm.compareTo(b.distanceKm)
        : (a, b) => a.name.compareTo(b.name));
    return list;
  }

  /// Toko terdekat untuk Beranda.
  List<FruitStore> nearest([int n = 2]) {
    final l = List.of(_all)..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return l.take(n).toList();
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      location = await _repo.currentLocation();
      area = await _repo.currentAreaName();
      _all = await _repo.fetchNearby(radiusKm: radiusKm);
    } catch (_) {}
    loading = false;
    notifyListeners();
  }

  Future<void> setRadius(double km) async {
    radiusKm = km;
    await load();
  }

  void setQuery(String v) {
    query = v;
    notifyListeners();
  }

  void setOnlyOpen(bool v) {
    onlyOpen = v;
    notifyListeners();
  }

  void setSort(StoreSort s) {
    sort = s;
    notifyListeners();
  }

  void select(String? id) {
    selectedId = id;
    notifyListeners();
  }
}
