import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'scan_handler.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({
    super.key,
    required this.onScan,
    this.closeAfterSuccess = true,
  });

  final Future<ScanResult> Function(String code) onScan;
  final bool closeAfterSuccess;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
    torchEnabled: false,
  );

  bool _busy = false;

  DateTime? _lastScanAt;
  static const Duration _scanCooldown = Duration(seconds: 1);

  String? _lastCode;
  DateTime? _lastCodeAt;
  static const Duration _sameCodeIgnore = Duration(seconds: 5);

  DateTime? _lastErrorToastAt;
  static const Duration _errorToastCooldown = Duration(milliseconds: 2500);

  DateTime? _errorCooldownUntil;
  static const Duration _afterErrorCooldown = Duration(seconds: 3);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _canShowErrorToast() {
    final now = DateTime.now();
    if (_lastErrorToastAt == null) {
      _lastErrorToastAt = now;
      return true;
    }
    if (now.difference(_lastErrorToastAt!) >= _errorToastCooldown) {
      _lastErrorToastAt = now;
      return true;
    }
    return false;
  }

  String _prettyError(Object e) {
    final s = e.toString();
    return s.startsWith('Exception: ') ? s.replaceFirst('Exception: ', '') : s;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final now = DateTime.now();

    if (_lastScanAt != null && now.difference(_lastScanAt!) < _scanCooldown) return;
    if (_errorCooldownUntil != null && now.isBefore(_errorCooldownUntil!)) return;

    if (_busy) return;
    if (capture.barcodes.isEmpty) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    if (_lastCode == code && _lastCodeAt != null && now.difference(_lastCodeAt!) < _sameCodeIgnore) {
      return;
    }

    _lastScanAt = now;
    _lastCode = code;
    _lastCodeAt = now;

    setState(() => _busy = true);

    try {
      final result = await widget.onScan(code);

      if (!mounted) return;

      if (widget.closeAfterSuccess) {
        Navigator.of(context).pop(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kód spracovaný')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      _errorCooldownUntil = DateTime.now().add(_afterErrorCooldown);

      if (_canShowErrorToast()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_prettyError(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ nastav si jazyk tu:
    // 'en' alebo 'nl'
    const String uiLang = 'en';

    String t(String sk, String en, String nl) {
      return switch (uiLang) {
        'nl' => nl,
        'en' => en,
        _ => sk,
      };
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                  tooltip: t('Zatvoriť', 'Close', 'Sluiten'),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.cameraswitch, color: Colors.white),
                  onPressed: () => _controller.switchCamera(),
                  tooltip: t('Prepnúť kameru', 'Switch camera', 'Camera wisselen'),
                ),
                IconButton(
                  icon: const Icon(Icons.flash_on, color: Colors.white),
                  onPressed: () async {
                    await _controller.toggleTorch();
                    if (mounted) setState(() {});
                  },
                  tooltip: t('Blesk', 'Flash', 'Flits'),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_busy) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
