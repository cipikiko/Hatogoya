import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class OrangeMaskOverlayPainter extends CustomPainter {
  final Uint8List mask;
  final int gw, gh;
  final int step;

  OrangeMaskOverlayPainter({
    required this.mask,
    required this.gw,
    required this.gh,
    required this.step,
  });

  int _idx(int x, int y) => y * gw + x;

  @override
  void paint(Canvas canvas, Size size) {
    // Zvýraznenie oranžovej časti: jemný cyan/teal overlay (nie žltá/oranžová/červená)
    final paint = Paint()
      ..color = const Color(0xFF00BCD4).withOpacity(0.22)
      ..style = PaintingStyle.fill;

    // Optimalizácia: spájaj súvislé "runy" v riadku do jedného rectu
    for (int y = 0; y < gh; y++) {
      int runStart = -1;

      for (int x = 0; x < gw; x++) {
        final v = mask[_idx(x, y)] == 1;

        if (v && runStart == -1) {
          runStart = x;
        } else if (!v && runStart != -1) {
          // ukonči run
          final left = runStart * step.toDouble();
          final top = y * step.toDouble();
          final width = (x - runStart) * step.toDouble();
          final height = step.toDouble();
          canvas.drawRect(Rect.fromLTWH(left, top, width, height), paint);
          runStart = -1;
        }
      }

      // ak run ostal otvorený do konca riadku
      if (runStart != -1) {
        final left = runStart * step.toDouble();
        final top = y * step.toDouble();
        final width = (gw - runStart) * step.toDouble();
        final height = step.toDouble();
        canvas.drawRect(Rect.fromLTWH(left, top, width, height), paint);
      }
    }

    // Jemný "glow" efekt cez blur (nenáročné)
    final glow = Paint()
      ..color = const Color(0xFF00BCD4).withOpacity(0.10)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6);

    canvas.drawRect(Offset.zero & size, glow);
  }

  @override
  bool shouldRepaint(covariant OrangeMaskOverlayPainter oldDelegate) {
    return oldDelegate.mask != mask ||
        oldDelegate.gw != gw ||
        oldDelegate.gh != gh ||
        oldDelegate.step != step;
  }
}
