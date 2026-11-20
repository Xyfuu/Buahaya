import 'fruit.dart';

/// Hasil deteksi satu jenis buah pada frame/foto.
class FruitDetection {
  const FruitDetection({required this.fruit, required this.total, required this.fresh});

  final Fruit fruit;
  final int total; // semua yang terdeteksi
  final int fresh; // yang dinilai segar
}

class LiveDetection {
  const LiveDetection(this.detections);
  final List<FruitDetection> detections;

  FruitDetection? get primary =>
      detections.isEmpty ? null : (List.of(detections)..sort((a, b) => b.total.compareTo(a.total))).first;
}

class ScanResult {
  const ScanResult(this.detections);
  final List<FruitDetection> detections;

  FruitDetection? get primary =>
      detections.isEmpty ? null : (List.of(detections)..sort((a, b) => b.fresh.compareTo(a.fresh))).first;
}
