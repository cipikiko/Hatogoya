import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'prefs_service.dart';

class HapticsService {
  static Future<void> tap() async {
    final enabled = await PrefsService.vibrationsEnabled();
    if (!enabled) return;

    final hasVibrator = await Vibration.hasVibrator();

    if (hasVibrator) {
      Vibration.vibrate(duration: 18);
    } else {
      HapticFeedback.selectionClick();
    }
  }
}
