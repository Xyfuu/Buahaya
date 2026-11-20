import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/fruit_scan_repository.dart';

enum CameraStatus { initializing, ready, denied, unavailable }

/// Pembungkus kamera (package `camera`) untuk layar Scan.
///
/// SLOT KAMERA: [controller] -> preview, [capture] -> foto untuk dikirim ke
/// backend lewat FruitScanRepository.analyzePhoto, dan [startLiveStream]
/// -> frame untuk FruitScanRepository.detectLive.
class ScanCamera extends ChangeNotifier {
  CameraController? controller;
  CameraStatus status = CameraStatus.initializing;
  bool torchOn = false;
  bool locked = false;
  double zoom = 1;
  double _minZoom = 1;
  double _maxZoom = 1;
  bool _streaming = false;
  DateTime _lastFrame = DateTime.fromMillisecondsSinceEpoch(0);
  bool _disposed = false;

  bool get isReady => status == CameraStatus.ready && controller != null;

  Future<void> initialize() async {
    status = CameraStatus.initializing;
    _safeNotify();
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        status = CameraStatus.unavailable;
        _safeNotify();
        return;
      }
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final c = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await c.initialize();
      if (_disposed) {
        await c.dispose();
        return;
      }
      controller = c;
      _minZoom = await c.getMinZoomLevel();
      _maxZoom = await c.getMaxZoomLevel();
      zoom = _minZoom;
      status = CameraStatus.ready;
    } on CameraException catch (e) {
      status = e.code.toLowerCase().contains('denied') ? CameraStatus.denied : CameraStatus.unavailable;
    } catch (_) {
      status = CameraStatus.unavailable;
    }
    _safeNotify();
  }

  Future<void> toggleTorch() async {
    final c = controller;
    if (c == null || !isReady) return;
    try {
      torchOn = !torchOn;
      await c.setFlashMode(torchOn ? FlashMode.torch : FlashMode.off);
    } catch (_) {
      torchOn = false;
    }
    _safeNotify();
  }

  /// 1x atau 2x.
  Future<void> setZoomStep(double step) async {
    final c = controller;
    if (c == null || !isReady) {
      zoom = step;
      _safeNotify();
      return;
    }
    try {
      final target = step.clamp(_minZoom, _maxZoom).toDouble();
      await c.setZoomLevel(target);
      zoom = step;
    } catch (_) {}
    _safeNotify();
  }

  /// Kunci fokus & exposure (AE/AF lock).
  Future<void> toggleLock() async {
    final c = controller;
    locked = !locked;
    if (c != null && isReady) {
      try {
        await c.setExposureMode(locked ? ExposureMode.locked : ExposureMode.auto);
        await c.setFocusMode(locked ? FocusMode.locked : FocusMode.auto);
      } catch (_) {}
    }
    _safeNotify();
  }

  /// Ambil foto. Mengembalikan path file atau null (mis. kamera tidak tersedia).
  Future<String?> capture() async {
    final c = controller;
    if (c == null || !isReady || c.value.isTakingPicture) return null;
    try {
      await stopLiveStream();
      final file = await c.takePicture();
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Kirim frame ke [onFrame] maksimal 1x per [interval].
  Future<void> startLiveStream(
    Future<void> Function(ScanFrame frame) onFrame, {
    Duration interval = const Duration(seconds: 1),
  }) async {
    final c = controller;
    if (c == null || !isReady || _streaming) return;
    try {
      _streaming = true;
      await c.startImageStream((image) {
        final now = DateTime.now();
        if (now.difference(_lastFrame) < interval) return;
        _lastFrame = now;
        onFrame(ScanFrame(
          width: image.width,
          height: image.height,
          planes: [for (final p in image.planes) p.bytes],
          rowStrides: [for (final p in image.planes) p.bytesPerRow],
          rotation: c.description.sensorOrientation,
        ));
      });
    } catch (_) {
      _streaming = false;
    }
  }

  Future<void> stopLiveStream() async {
    final c = controller;
    if (c == null || !_streaming) return;
    _streaming = false;
    try {
      await c.stopImageStream();
    } catch (_) {}
  }

  Future<void> disposeCamera() async {
    await stopLiveStream();
    final c = controller;
    controller = null;
    status = CameraStatus.initializing;
    await c?.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    stopLiveStream();
    controller?.dispose();
    super.dispose();
  }
}
