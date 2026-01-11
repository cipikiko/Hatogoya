// plants_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/tokens.dart';
import '../widgets/neon.dart';
import '../lang/strings.dart';

class PlantItem {
  final int id; // 1..28
  final String name;
  final String assetPath;

  const PlantItem({
    required this.id,
    required this.name,
    required this.assetPath,
  });
}

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

  final List<PlantItem> _plants = const [
    PlantItem(
      id: 1,
      name: "Cornus controversa 'Variegata'",
      assetPath: "lib/utils/plants/Cornus controversa.jpg",
    ),
    PlantItem(
      id: 2,
      name: "Sciadopitys verticillata 'Wiel's Beauty'",
      assetPath: "lib/utils/plants/Sciadopitys verticillata Wiel’s Beauty.jpg",
    ),
    PlantItem(
      id: 3,
      name: "Cedrus atlantica 'Glauca'",
      assetPath: "lib/utils/plants/Cedrus atlantica Glauca.jpg",
    ),
    PlantItem(
      id: 4,
      name: "Camellia japonica",
      assetPath: "lib/utils/plants/Camellia japonica.jpg",
    ),
    PlantItem(
      id: 5,
      name: "Ginkgo biloba 'China Pendula'",
      assetPath: "lib/utils/plants/Ginkgo biloba China Pendula.jpg",
    ),
    PlantItem(
      id: 6,
      name: "Acer japonica 'Orange Dream'",
      assetPath: "lib/utils/plants/Acer japonica Orange Dream.jpg",
    ),
    PlantItem(
      id: 7,
      name: "Ginkgo biloba 'Mariken'",
      assetPath: "lib/utils/plants/Ginkgo biloba Mariken.jpg",
    ),
    PlantItem(
      id: 8,
      name: "Cedrus deodara 'Aurea'",
      assetPath: "lib/utils/plants/Cedrus deodara Aurea.jpg",
    ),
    PlantItem(
      id: 9,
      name: "Cedrus atlantica 'Glauca Pendula'",
      assetPath: "lib/utils/plants/Cedrus atlantica Glauca Pendula.jpg",
    ),
    PlantItem(
      id: 10,
      name: "Sequoiadendron giganteum",
      assetPath: "lib/utils/plants/Sequoiadendron giganteum.jpg",
    ),
    PlantItem(
      id: 11,
      name: "Sequoia sempervirens 'Loma Prieta Spike'",
      assetPath: "lib/utils/plants/Sequoia sempervirens Loma Prieta Spike.jpg",
    ),
    PlantItem(
      id: 12,
      name: "Pinus sabiniana 'Isabella'",
      assetPath: "lib/utils/plants/Pinus sabiniana Isabella.JPG",
    ),
    PlantItem(
      id: 13,
      name: "Cornus × venus",
      assetPath: "lib/utils/plants/Cornus kousa Venus.jpg",
    ),
    PlantItem(
      id: 14,
      name: "Liquidambar styraciflua",
      assetPath: "lib/utils/plants/Liquidambar styraciflua.jpg",
    ),
    PlantItem(
      id: 15,
      name: "Magnolia × 'Coral Lake'",
      assetPath: "lib/utils/plants/Magnolia × Coral Lake.JPG",
    ),
    PlantItem(
      id: 16,
      name: "Magnolia grandiflora 'Kay Parris'",
      assetPath: "lib/utils/plants/Magnolia grandiflora Kay Parris.JPG",
    ),
    PlantItem(
      id: 17,
      name: "Pinus nigra",
      assetPath: "lib/utils/plants/Pinus nigra.jpg",
    ),
    PlantItem(
      id: 18,
      name: "Liriodendron tulipifera",
      assetPath: "lib/utils/plants/Liriodendron tulipifera.jpg",
    ),
    PlantItem(
      id: 19,
      name: "Sequoia sempervirens Winter Blue",
      assetPath: "lib/utils/plants/Sequoia sempervirens Winter Blue.jpg",
    ),
    PlantItem(
      id: 20,
      name: "Abies koreana 'Kosmos'",
      assetPath: "lib/utils/plants/Abies koreana Kosmos.jpg",
    ),
    PlantItem(
      id: 21,
      name: "Sequoia sempervirens Xeno",
      assetPath: "lib/utils/plants/Sequoia sempervirens Xeno.jpg",
    ),
    PlantItem(
      id: 22,
      name: "Abies vejarii 'Mountain Blue'",
      assetPath: "lib/utils/plants/Abies vejarii ‘Mountain Blue’.jpg",
    ),
    PlantItem(
      id: 23,
      name: "Magnolia denudata 'Yellow River'",
      assetPath: "lib/utils/plants/Magnolia denudata ‘Yellow River’.jpg",
    ),
    PlantItem(
      id: 24,
      name: "Fagus sylvatica 'Black Swan'",
      assetPath: "lib/utils/plants/Fagus sylvatica ‘Black Swan’.jpg",
    ),
    PlantItem(
      id: 25,
      name: "Quercus frainetto",
      assetPath: "lib/utils/plants/Quercus frainetto.jpg",
    ),
    PlantItem(
      id: 26,
      name: "Platanus × acerifolia",
      assetPath: "lib/utils/plants/Platanus × acerifolia.jpg",
    ),
  ];


  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 220;
      if (shouldShow != _showScrollTop && mounted) {
        setState(() => _showScrollTop = shouldShow);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ EN Wikipedia (Search) - vždy funguje
  String _wikiUrlForSearch(String plantName) {
    final q = plantName.trim().replaceAll('×', 'x');
    return 'https://en.wikipedia.org/wiki/Special:Search?search=${Uri.encodeComponent(q)}';
  }

  Future<void> _openUrl(String url) async {
    final tr = context.tr;
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.plantsCouldNotOpenLink)),
      );
    }
  }

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

  void _showPlantDialog(PlantItem plant) {
    final wikiUrl = _wikiUrlForSearch(plant.name);
    final tr = context.tr;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final onPrimary = AppTokens.textPrimary;
        final secondary = AppTokens.textSecondary;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          backgroundColor: Colors.transparent,
          child: NeonCard(
            color: AppTokens.cardDark,
            shadows: AppTokens.tileShadow,
            radius: 18,
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plant.name,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: onPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: Icon(Icons.close, color: secondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      height: 260,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTokens.cardBorder),
                      ),
                      child: _plantImage(
                        plant.assetPath,
                        width: double.infinity,
                        height: 260,
                        radius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr.plantDescription(plant.id),
                      style: AppTokens.body.copyWith(
                        color: secondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () => _openUrl(wikiUrl),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new, color: AppTokens.emerald500, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              tr.plantsOpenWikipedia,
                              style: TextStyle(
                                color: AppTokens.emerald500,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
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
          ),
        );
      },
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
      SortMode.original => tr.plantsSortDefault, // ✅ default text
      SortMode.az => tr.plantsSortAzOn,
      SortMode.za => tr.plantsSortZaOn,
    };
  }

  List<PlantItem> _filteredAndSorted(List<PlantItem> list) {
    final q = _searchQuery.trim().toLowerCase();
    var out = list.where((p) => p.name.toLowerCase().contains(q)).toList();

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
    final filteredPlants = _filteredAndSorted(_plants);

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

              // ✅ Sort (VĽAVO)
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
                  return NeonCard(
                    color: AppTokens.cardDark,
                    shadows: AppTokens.tileShadow,
                    radius: AppTokens.radiusMd,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      onTap: () => _showPlantDialog(plant),
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
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // ✅ Scroll-to-top button (pravý dolný roh, až po scrolle)
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
