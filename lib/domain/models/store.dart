class FruitStore {
  const FruitStore({
    required this.id,
    required this.name,
    required this.distanceKm,
    required this.opensAtMinutes,
    required this.closesAtMinutes,
    required this.lat,
    required this.lng,
    this.area = '',
    this.address = '',
    this.imageUrl,
  });

  final String id;
  final String name;
  final double distanceKm;
  final int opensAtMinutes;
  final int closesAtMinutes;
  final double lat;
  final double lng;
  final String area;
  final String address;

    final String? imageUrl;

  bool isOpenAt(DateTime t) {
    final m = t.hour * 60 + t.minute;
    return m >= opensAtMinutes && m < closesAtMinutes;
  }

  static String _hm(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';

  String get hoursLabel => '${_hm(opensAtMinutes)}–${_hm(closesAtMinutes)} WIB';
}
