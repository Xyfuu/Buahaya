import '../../domain/models/scan.dart';
import '../../domain/repositories/fruit_scan_repository.dart';
import 'mock_seed.dart';

class MockFruitScanRepository implements FruitScanRepository {
  @override
  Future<LiveDetection?> detectLive(ScanFrame frame) async {
    return const LiveDetection([FruitDetection(fruit: MockSeed.apple, total: 4, fresh: 3)]);
  }

  @override
  Future<ScanResult> analyzePhoto(String imagePath) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return const ScanResult([FruitDetection(fruit: MockSeed.apple, total: 9, fresh: 7)]);
  }
}
