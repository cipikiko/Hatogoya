// lib/game/plant_dialog.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/tokens.dart';
import '../widgets/neon.dart';
import '../lang/strings.dart';

class PlantItem {
  final int id;
  final String name;
  final String assetPath;

  const PlantItem({
    required this.id,
    required this.name,
    required this.assetPath,
  });
}

String _wikiUrl(String name) {
  final q = name.replaceAll('×', 'x');
  return 'https://en.wikipedia.org/wiki/Special:Search?search=${Uri.encodeComponent(q)}';
}

Future<void> _openUrl(BuildContext ctx, String url) async {
  final tr = ctx.tr;

  final ok = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );

  if (!ok && ctx.mounted) {
    // ✅ používaj ScaffoldMessenger z rovnakého navigator stromu (dialógu)
    ScaffoldMessenger.maybeOf(ctx)?.showSnackBar(
      SnackBar(content: Text(tr.plantsCouldNotOpenLink)),
    );
  }
}

Widget _image(String path) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppTokens.cardDark,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported, color: AppTokens.textSecondary),
      ),
    ),
  );
}

/// ✅ Dôležité: vráť Future a použi rootNavigator
Future<void> showPlantDialog(BuildContext context, PlantItem plant, {bool discovered = false}) async {
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    useRootNavigator: true, // ✅ FIX: vždy ten istý Navigator
    barrierDismissible: true,
    builder: (dialogCtx) {
      final tr = dialogCtx.tr;

      void close() {
        // ✅ popni root navigator (istý)
        Navigator.of(dialogCtx, rootNavigator: true).pop();
      }

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: NeonCard(
          color: AppTokens.cardDark,
          radius: 18,
          padding: const EdgeInsets.all(18),
          shadows: AppTokens.tileShadow,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Stack(
              children: [
                // 👇 pôvodný obsah (len obalený Paddingom, aby sa nebil s badge)
                Padding(
                  padding: const EdgeInsets.only(bottom: 36), // nech badge neprekrýva text
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plant.name,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTokens.textPrimary,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: AppTokens.textSecondary),
                              onPressed: close,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 260,
                          width: double.infinity,
                          child: _image(plant.assetPath),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          tr.plantDescription(plant.id),
                          style: AppTokens.body.copyWith(
                            color: AppTokens.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => _openUrl(dialogCtx, _wikiUrl(plant.name)),
                          icon: const Icon(Icons.open_in_new),
                          label: Text(tr.plantsOpenWikipedia),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ badge vpravo dole
                if (discovered)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTokens.emerald500.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppTokens.emerald500.withValues(alpha: 0.55)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, size: 16, color: AppTokens.emerald500),
                          const SizedBox(width: 6),
                          Text(
                            // ✅ “Discovered” znie najlepšie (nie “Found”)
                            tr.commonDiscovered, // pridáme do strings
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                              color: AppTokens.emerald500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}