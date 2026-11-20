import 'dart:typed_data';

import '../models/scan.dart';

/// Frame kamera mentah untuk deteksi live (format YUV420).
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

/// SLOT BACKEND UNTUK SCAN BUAH.
///
/// - [detectLive]   : dipanggil periodik (~1x/detik) saat preview kamera aktif.
/// - [analyzePhoto] : dipanggil saat tombol shutter ditekan; kirim foto ke
///                    backend/model AI dan kembalikan hasil deteksi.
abstract class FruitScanRepository {
  Future<LiveDetection?> detectLive(ScanFrame frame);

  Future<ScanResult> analyzePhoto(String imagePath);
}
