import 'package:flutter/material.dart';

import '../data/plants_data.dart' as data;
import '../game/plant_dialog.dart' as dialog;
import '../lang/strings.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

enum SortMode { original, az, za }

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  SortMode _sortMode = SortMode.original;

  bool _showScrollTop = false;

  bool _loading = true;
  Set<int> _discoveredIds = <int>{}; // ✅ tu budú ID objavených rastlín

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 220;
      if (shouldShow != _showScrollTop && mounted) {
        setState(() => _showScrollTop = shouldShow);
      }
    });

    _init();
  }

  Future<void> _init() async {
    final token = await AuthService.getToken();

    // Ak nie je prihlásený user, len vypni loading a zobraz bez fajok
    if (token == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    try {
      final prof = await ApiService.getProfile(token);
      final ids = List<int>.from(prof['discoveredPlantIds'] ?? const []);
      if (!mounted) return;
      setState(() {
        _discoveredIds = ids.toSet();
        _loading = false;
      });
    } catch (_) {
      // fallback: nepadni celú obrazovku
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  dialog.PlantItem _toDialogPlant(data.PlantItem p) => dialog.PlantItem(
    id: p.id,
    name: p.name,
    assetPath: p.assetPath,
  );

  Widget _plantImage(
      String assetPath, {
        double? width,
        double? height,
        BorderRadius? radius,
      }) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(12),
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: AppTokens.cardDark,
          alignment: Alignment.center,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppTokens.textSecondary,
          ),
        ),
      ),
    );
  }

  void _cycleSortMode() {
    setState(() {
      _sortMode = switch (_sortMode) {
        SortMode.original => SortMode.az,
        SortMode.az => SortMode.za,
        SortMode.za => SortMode.original,
      };
    });
  }

  String _sortLabel(Tr tr) {
    return switch (_sortMode) {
      SortMode.original => tr.plantsSortDefault,
      SortMode.az => tr.plantsSortAzOn,
      SortMode.za => tr.plantsSortZaOn,
    };
  }

  List<data.PlantItem> _filteredAndSorted(List<data.PlantItem> list) {
    final q = _searchQuery.trim().toLowerCase();
    final out = list.where((p) => p.name.toLowerCase().contains(q)).toList();

    switch (_sortMode) {
      case SortMode.original:
        out.sort((a, b) => a.id.compareTo(b.id));
        break;
      case SortMode.az:
        out.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortMode.za:
        out.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
    }

    return out;
  }

  Future<void> _scrollToTop() async {
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final filteredPlants = _filteredAndSorted(data.plants);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                tr.plantsTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tr.plantsSubtitle,
                style: AppTokens.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _searchController,
                style: TextStyle(color: AppTokens.textPrimary),
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: tr.plantsSearchHint,
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

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: _cycleSortMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTokens.cardDark,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTokens.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sort_by_alpha, size: 18, color: AppTokens.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          _sortLabel(tr),
                          style: TextStyle(
                            color: AppTokens.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Column(
                children: filteredPlants.map((plant) {
                  final discovered = _discoveredIds.contains(plant.id);

                  return NeonCard(
                    color: AppTokens.cardDark,
                    shadows: AppTokens.tileShadow,
                    radius: AppTokens.radiusMd,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      onTap: () => dialog.showPlantDialog(
                        context,
                        _toDialogPlant(plant),
                        discovered: discovered,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                              border: Border.all(color: AppTokens.cardBorder),
                            ),
                            child: _plantImage(
                              plant.assetPath,
                              width: 50,
                              height: 50,
                              radius: BorderRadius.circular(AppTokens.radiusSm),
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              plant.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppTokens.textPrimary,
                              ),
                            ),
                          ),

                          // ✅ fajka napravo, len ak objavené
                          if (discovered) ...[
                            const SizedBox(width: 10),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: AppTokens.emerald500.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppTokens.emerald500.withValues(alpha: 0.55)),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: AppTokens.emerald500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          right: 16,
          bottom: _showScrollTop ? 16 : -80,
          child: GestureDetector(
            onTap: _scrollToTop,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTokens.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTokens.cardBorder),
                boxShadow: AppTokens.glow(AppTokens.emerald500, blur: 14, alpha: .14),
              ),
              child: Icon(Icons.keyboard_arrow_up, color: AppTokens.textPrimary, size: 26),
            ),
          ),
        ),
      ],
    );
  }
}
