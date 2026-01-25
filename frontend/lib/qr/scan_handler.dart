import 'package:flutter/material.dart';
import '../lang/strings.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ScanResult {
  final int plantId;
  final bool newlyDiscovered;
  final int foundCount;
  final List<int> lastPlants;

  const ScanResult({
    required this.plantId,
    required this.newlyDiscovered,
    required this.foundCount,
    required this.lastPlants,
  });
}

/// QR handler for Hatogoya:
/// - accepts only your official QR codes (validated by backend via plants.qr_token)
/// - does NOT open any links
/// - records discovery and returns updated progress + recently viewed
Future<ScanResult> handleScan(BuildContext context, String code) async {
  final qrToken = code.trim();
  final tr = context.tr;
  final token = await AuthService.getToken();
  if (token == null) {
    throw Exception(tr.scanLoginFirst);

  }

  final res = await ApiService.scanByQrToken(context, qrToken, token);

  return ScanResult(
    plantId: (res['plant_id'] as num).toInt(),
    newlyDiscovered: (res['newly_discovered'] as bool?) ?? false,
    foundCount: (res['foundCount'] as num?)?.toInt() ?? 0,
    lastPlants: List<int>.from(res['lastPlants'] ?? const []),
  );
}
