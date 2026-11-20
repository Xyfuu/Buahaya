import '../models/store.dart';

class GeoPoint {
  const GeoPoint(this.lat, this.lng);
  final double lat;
  final double lng;
}

abstract class StoreRepository {
    Future<GeoPoint> currentLocation();

  Future<String> currentAreaName();

  Future<List<FruitStore>> fetchNearby({required double radiusKm});
}
