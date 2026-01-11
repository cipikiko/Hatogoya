import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';
import '../qr/qr.dart'; // QR skener + handler
import '../lang/strings.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    // demo numbers (real values later)
    const foundPlants = 47;
    const totalPlants = 120;
    const progress = foundPlants / totalPlants; // 0.39...
    final percent = (progress * 100).round(); // 39

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.discoverTitle, style: AppTokens.h1),
          const SizedBox(height: 4),
          Text(tr.discoverSubtitle, style: AppTokens.body),
          const SizedBox(height: 20),

          // 🔍 Search Bar
          TextField(
            style: TextStyle(color: AppTokens.textPrimary),
            decoration: InputDecoration(
              hintText: tr.discoverSearchHint,
              hintStyle: TextStyle(color: AppTokens.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppTokens.textSecondary),
              filled: true,
              fillColor: AppTokens.cardDark,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                borderSide: BorderSide(color: AppTokens.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                borderSide: const BorderSide(color: AppTokens.emerald500),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🌿 Scan Button (otvorí QR scanner)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => ScannerPage(
                    onScan: (code) => handleScan(ctx, code),
                  ),
                ),
              );
            },
            child: NeonCard(
              gradient: AppTokens.tealGradient,
              shadows: AppTokens.glow(AppTokens.green400, blur: 18),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              radius: AppTokens.radiusMd,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr.discoverScanTitle, style: AppTokens.titleWhite),
                        const SizedBox(height: 2),
                        Text(
                          tr.discoverScanSubtitle,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // 📊 Collection Progress
          NeonCard(
            color: AppTokens.cardDark,
            shadows: AppTokens.tileShadow,
            radius: AppTokens.radiusMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.discoverCollectionTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const GradientProgressBar(value: progress, height: 8),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr.discoverCollectionProgress(foundPlants, totalPlants),
                      style: TextStyle(fontSize: 13, color: AppTokens.textSecondary),
                    ),
                    Text(
                      tr.discoverCollectionPercent(percent),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.emerald500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Text(
            tr.discoverLastCollected,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),


        ],
      ),
    );
  }
}

// 🌿 Plant Card bez obrázku (neon štýl)
class PlantCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String rarity;
  final String zone;
  final Color tagColor;

  const PlantCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.rarity,
    required this.zone,
    required this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      color: AppTokens.cardDark,
      shadows: AppTokens.tileShadow,
      radius: AppTokens.radiusMd,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 📦 malé „logo“ miesto obrázka
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTokens.cardDark,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              border: Border.all(color: AppTokens.cardBorder),
            ),
            child: Center(
              child: Icon(Icons.eco, color: AppTokens.textSecondary, size: 22),
            ),
          ),
          const SizedBox(width: 12),

          // 🌿 Textová časť
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rarity,
                        style: TextStyle(
                          color: tagColor.darken(),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.location_on_outlined, size: 14, color: AppTokens.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      zone,
                      style: TextStyle(fontSize: 12, color: AppTokens.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🌱 Locked plant card (neon štýl)
class PlantLockedCard extends StatelessWidget {
  final String rarity;
  final Color color;

  const PlantLockedCard({
    super.key,
    required this.rarity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return NeonCard(
      color: AppTokens.cardDark,
      shadows: AppTokens.tileShadow,
      radius: AppTokens.radiusMd,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 28, color: AppTokens.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '???',
                  style: TextStyle(
                    color: AppTokens.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tr.discoverNotDiscoveredYet,
                  style: TextStyle(color: AppTokens.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rarity,
              style: TextStyle(
                color: color.darken(),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🌈 Pomocná funkcia na stmavenie farby
extension ColorShade on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
