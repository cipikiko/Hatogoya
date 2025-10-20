import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Discover Plants',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Explore and collect botanical species',
            style: TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),

          // 🔍 Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search plants...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🌿 Scan Button
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ScanPlantDialog(),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.document_scanner_outlined,
                      color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Column(
                    children: [
                      Text('Scan a Plant',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text('Use your camera to identify plants',
                          style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // 📊 Collection Progress
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3))
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Collection',
                    style:
                    TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: 0.39,
                  backgroundColor: Colors.grey[300],
                  color: AppColors.primaryGreen,
                  minHeight: 6,
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('47 of 120 plants discovered',
                        style: TextStyle(fontSize: 13, color: Colors.black54)),
                    Text('39% Complete',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text('Plant Collection',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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

// 🌿 Plant Card bez obrázku
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 📦 Placeholder namiesto obrázka
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Text(
                  'Obr.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
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
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: tagColor.withValues(alpha: 0.3),
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
                      Text(zone,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🌱 Locked plant card
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        leading: const Icon(Icons.lock_outline, size: 40, color: Colors.grey),
        title: const Text('???',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: const Text('Not discovered yet',
            style: TextStyle(color: Colors.black54)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            rarity,
            style: TextStyle(
              color: color.darken(),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// 📸 Dialog pre skenovanie
class ScanPlantDialog extends StatelessWidget {
  const ScanPlantDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Scan a Plant',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Take a photo or upload an image to identify plants in the garden',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: const Center(
                child: Icon(Icons.camera_alt_outlined,
                    size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Take Photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Upload'),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.lightBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Point your camera at a plant in the garden for instant identification and information.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textGrey, height: 1.3),
                    ),
                  ),
                ],
              ),
            )
          ],
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
