import 'package:flutter/material.dart';

import '../data/plants_data.dart' as data;
import '../game/plant_dialog.dart' as dialog;
import '../lang/strings.dart';
import '../qr/qr.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';



class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int foundPlants = 0;
  List<int> lastCollectedIds = const [];

  bool _loading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await AuthService.getToken();
    if (!mounted) return;
    setState(() => _token = token);

    if (token != null) {
      await _loadProfile(token);
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _loadProfile(String token) async {
    final prof = await ApiService.getProfile(context, token);
    if (!mounted) return;
    setState(() {
      foundPlants = (prof['foundCount'] as num?)?.toInt() ?? 0;
      lastCollectedIds = List<int>.from(prof['lastPlants'] ?? const []);
    });
  }


  dialog.PlantItem _toDialogPlant(data.PlantItem p) => dialog.PlantItem(
    id: p.id,
    name: p.name,
    assetPath: p.assetPath,
  );

  Future<void> _startScan() async {
    final token = _token;
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Najprv sa prihlás.')),
      );
      return;
    }

    final result = await Navigator.push<ScanResult>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ScannerPage(
          onScan: (code) => handleScan(ctx, code),
        ),
      ),
    );

    if (result == null || !mounted) return;

    // Update progress + recently directly from scan response
    setState(() {
      foundPlants = result.foundCount;
      lastCollectedIds = result.lastPlants;
    });

    final dataPlant = data.plantById[result.plantId];
    if (dataPlant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Neznáma rastlina (ID mimo 1..26).')),
      );
      return;
    }

    await dialog.showPlantDialog(context, _toDialogPlant(dataPlant));
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scanGradient = isDark ? AppTokens.tealGradientDark : AppTokens.tealGradientLight;
    final totalPlants = data.plants.length;
    final progress = totalPlants == 0 ? 0.0 : (foundPlants / totalPlants).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr.discoverTitle, style: AppTokens.h1),
          const SizedBox(height: 4),
          Text(tr.discoverSubtitle, style: AppTokens.body),

          const SizedBox(height: 20),

          // 🌿 Scan Button
          GestureDetector(
            onTap: _startScan,
            child: NeonCard(
              gradient: scanGradient, // ✅ tu
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
                GradientProgressBar(value: progress, height: 8),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$foundPlants / $totalPlants",
                      style: TextStyle(fontSize: 13, color: AppTokens.textSecondary),
                    ),
                    Text(
                      "$percent%",
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

          Column(
            children: lastCollectedIds.map((id) {
              final plant = data.plantById[id];
              if (plant == null) return const SizedBox.shrink();

              return NeonCard(
                color: AppTokens.cardDark,
                shadows: AppTokens.tileShadow,
                radius: AppTokens.radiusMd,
                padding: EdgeInsets.zero, // ✅ padding presunieme do InkWell kontajnera
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  onTap: () => dialog.showPlantDialog(context, _toDialogPlant(plant)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                          child: Image.asset(
                            plant.assetPath,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 48,
                              height: 48,
                              color: AppTokens.cardDark,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: AppTokens.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            plant.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTokens.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

        ],
      ),
    );
  }
}
