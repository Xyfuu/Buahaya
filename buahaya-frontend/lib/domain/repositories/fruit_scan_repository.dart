import 'dart:typed_data';

import '../models/scan.dart';

class ScanFrame {
  const ScanFrame({
    required this.width,
    required this.height,
    required this.planes,
    required this.rowStrides,
    this.rotation = 0,
  });

  final int width;
  final int height;
  final List<Uint8List> planes;
  final List<int> rowStrides;
  final int rotation;
}

abstract class FruitScanRepository {
  Future<LiveDetection?> detectLive(ScanFrame frame);

  Future<ScanResult> analyzePhoto(String imagePath);
}
