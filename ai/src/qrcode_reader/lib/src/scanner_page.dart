import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatefulWidget {
  final FutureOr<void> Function(String code) onScan;
  const ScannerPage({super.key, required this.onScan});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  CameraController? _controller;
  late final BarcodeScanner _scanner;
  bool _handling = false;
  bool _initialized = false;
  StreamSubscription? _cameraStream;

  @override
  void initState() {
    super.initState();
    _scanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
    _init();
  }

  Future<void> _init() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
      }
      return;
    }

    final cameras = await availableCameras();
    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      back,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // best for Android ML Kit
    );

    await controller.initialize();
    await controller.startImageStream(_processImage);
    if (!mounted) return;
    setState(() {
      _controller = controller;
      _initialized = true;
    });
  }

  int _cooldownMs = 900;
  DateTime _lastTry = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _processImage(CameraImage image) async {
    if (_handling) return;
    final now = DateTime.now();
    if (now.difference(_lastTry).inMilliseconds < _cooldownMs) return;
    _lastTry = now;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final InputImageRotation rotation = InputImageRotation.rotation0deg; // camera plugin gives rotated bytes already
      final InputImageFormat format = InputImageFormat.nv21;

      final planeData = image.planes.map(
        (Plane plane) => InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        ),
      ).toList();

      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: rotation,
        inputImageFormat: format,
        planeData: planeData,
      );

      final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
      final barcodes = await _scanner.processImage(inputImage);

      final String? value = barcodes.map((b) => b.rawValue).whereType<String>().toSet().firstOrNull;
      if (value == null) return;

      _handling = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR: $value')));
      }
      await widget.onScan(value);
    } catch (_) {
      // swallow; we’re live processing
    } finally {
      // let it rescan after a second, if desired
      Future.delayed(Duration(milliseconds: _cooldownMs)).then((_) => _handling = false);
    }
  }

  @override
  void dispose() {
    _cameraStream?.cancel();
    _controller?.dispose();
    _scanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialized && _controller != null
          ? Stack(
              children: [
                CameraPreview(_controller!),
                const _Overlay(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _Overlay extends StatelessWidget {
  const _Overlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 4),
        ),
        margin: const EdgeInsets.all(24),
      ),
    );
  }
}
