import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Discover Plants', style: AppTokens.h1),
          const SizedBox(height: 4),
          const Text('Explore and collect botanical species', style: AppTokens.body),
          const SizedBox(height: 20),

          // 🔍 Search Bar
          TextField(
            style: const TextStyle(color: AppTokens.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search plants...',
              hintStyle: const TextStyle(color: AppTokens.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppTokens.textSecondary),
              filled: true,
              fillColor: AppTokens.cardDark,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                borderSide: const BorderSide(color: AppTokens.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                borderSide: const BorderSide(color: AppTokens.emerald500),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🌿 Scan Button (neon tyrkys)
          GestureDetector(
            onTap: () {
              showDialog(context: context, builder: (context) => const ScanPlantDialog());
            },
            child: NeonCard(
              gradient: AppTokens.tealGradient,
              shadows: AppTokens.glow(AppTokens.teal400, blur: 18),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              radius: AppTokens.radiusMd,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.document_scanner_outlined, color: Colors.white, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Scan a Plant', style: AppTokens.titleWhite),
                        SizedBox(height: 2),
                        Text('Use your camera to identify plants',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // 📊 Collection Progress (dark card + gradient progress)
          NeonCard(
            color: AppTokens.cardDark,
            shadows: AppTokens.tileShadow,
            radius: AppTokens.radiusMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Collection',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTokens.textPrimary)),
                const SizedBox(height: 8),
                const GradientProgressBar(value: 0.39, height: 8),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('47 of 120 plants discovered',
                        style: TextStyle(fontSize: 13, color: AppTokens.textSecondary)),
                    Text('39% Complete',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.emerald500,
                        )),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text('Plant Collection',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTokens.textPrimary)),
          const SizedBox(height: 10),

          // 🪴 Rastliny (bez obrázkov)
          const PlantCard(
            name: 'Monstera Deliciosa',
            subtitle: 'Monstera deliciosa',
            rarity: 'Common',
            zone: 'Tropical Zone A',
            tagColor: Color(0xFFA5D6A7),
          ),
          const PlantCard(
            name: 'Succulent Collection',
            subtitle: 'Various species',
            rarity: 'Uncommon',
            zone: 'Desert Garden',
            tagColor: Color(0xFF81D4FA),
          ),
          const PlantCard(
            name: 'Garden Flowers',
            subtitle: 'Mixed varieties',
            rarity: 'Common',
            zone: 'Rose Garden',
            tagColor: Color(0xFFA5D6A7),
          ),
          const PlantLockedCard(rarity: 'Rare', color: Color(0xFFCE93D8)),
          const PlantLockedCard(rarity: 'Epic', color: Color(0xFFFFCC80)),
        ],
      ),
    );
  }
}
/// kra kra kra

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
            child: const Center(
              child: Icon(Icons.eco, color: AppTokens.textSecondary, size: 22),
            ),
          ),
          const SizedBox(width: 12),

          // 🌿 Textová časť
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: AppTokens.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                Text(subtitle,
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, color: AppTokens.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.25),
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
                    const Icon(Icons.location_on_outlined, size: 14, color: AppTokens.textSecondary),
                    const SizedBox(width: 4),
                    Text(zone, style: const TextStyle(fontSize: 12, color: AppTokens.textSecondary)),
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
    return NeonCard(
      color: AppTokens.cardDark,
      shadows: AppTokens.tileShadow,
      radius: AppTokens.radiusMd,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 28, color: AppTokens.textSecondary),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('???',
                    style: TextStyle(
                        color: AppTokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 2),
                Text('Not discovered yet', style: TextStyle(color: AppTokens.textSecondary)),
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

// 📸 Dialog pre skenovanie (temný panel + neon prvky)
class ScanPlantDialog extends StatelessWidget {
  const ScanPlantDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTokens.panelGradient(),
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: AppTokens.cardBorder),
          boxShadow: AppTokens.tileShadow,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Scan a Plant',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTokens.textPrimary,
                    )),
                const SizedBox(height: 6),
                const Text(
                  'Choose how you want to identify the plant',
                  textAlign: TextAlign.center,
                  style: AppTokens.body,
                ),
                const SizedBox(height: 16),

                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTokens.cardDark,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    border: const Border.fromBorderSide(BorderSide(color: AppTokens.cardBorder)),
                  ),
                  child: const Center(
                    child: Icon(Icons.document_scanner_outlined,
                        size: 48, color: AppTokens.textSecondary),
                  ),
                ),

                const SizedBox(height: 16),

                // CTA buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Scan Plant (Camera)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.teal600,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.upload_file_outlined),
                        label: const Text('Upload Photo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTokens.textPrimary,
                          side: const BorderSide(color: AppTokens.teal600),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan QR Code'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTokens.textPrimary,
                          side: const BorderSide(color: AppTokens.teal600),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTokens.cardDark,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    border: const Border.fromBorderSide(BorderSide(color: AppTokens.cardBorder)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: You can identify plants by taking a photo, uploading an image, or scanning a QR code in the garden.',
                          style: AppTokens.body,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
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
