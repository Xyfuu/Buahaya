import '../../domain/models/store.dart';
import '../../domain/repositories/store_repository.dart';
import 'mock_seed.dart';

class MockStoreRepository implements StoreRepository {
  @override
  Future<GeoPoint> currentLocation() async =>
      const GeoPoint(MockSeed.userLat, MockSeed.userLng);

  @override
  Future<String> currentAreaName() async => 'Kebayoran Baru';

  @override
  Future<List<FruitStore>> fetchNearby({required double radiusKm}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return MockSeed.stores.where((s) => s.distanceKm <= radiusKm).toList();
  }
}
