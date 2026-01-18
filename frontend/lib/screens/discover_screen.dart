import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';
import '../qr/qr.dart'; // QR skener + handler
import '../lang/strings.dart';

// 🔹 Tvoj kompletný zoznam rastlín
final List<Map<String, String>> allPlants = [
  {"name": "Cornus controversa 'Variegata'", "assetPath": "lib/utils/plants/Cornus controversa.jpg"},
  {"name": "Sciadopitys verticillata 'Wiel's Beauty'", "assetPath": "lib/utils/plants/Sciadopitys verticillata Wiel’s Beauty.jpg"},
  {"name": "Cedrus atlantica 'Glauca'", "assetPath": "lib/utils/plants/Cedrus atlantica Glauca.jpg"},
  {"name": "Camellia japonica", "assetPath": "lib/utils/plants/Camellia japonica.jpg"},
  {"name": "Ginkgo biloba 'China Pendula'", "assetPath": "lib/utils/plants/Ginkgo biloba China Pendula.jpg"},
  {"name": "Acer japonica 'Orange Dream'", "assetPath": "lib/utils/plants/Acer japonica Orange Dream.jpg"},
  {"name": "Ginkgo biloba 'Mariken'", "assetPath": "lib/utils/plants/Ginkgo biloba Mariken.jpg"},
  {"name": "Cedrus deodara 'Aurea'", "assetPath": "lib/utils/plants/Cedrus deodara Aurea.jpg"},
  {"name": "Cedrus atlantica 'Glauca Pendula'", "assetPath": "lib/utils/plants/Cedrus atlantica Glauca Pendula.jpg"},
  {"name": "Sequoiadendron giganteum", "assetPath": "lib/utils/plants/Sequoiadendron giganteum.jpg"},
  {"name": "Sequoia sempervirens 'Loma Prieta Spike'", "assetPath": "lib/utils/plants/Sequoia sempervirens Loma Prieta Spike.jpg"},
  {"name": "Pinus sabiniana 'Isabella'", "assetPath": "lib/utils/plants/Pinus sabiniana Isabella.JPG"},
  {"name": "Cornus × venus", "assetPath": "lib/utils/plants/Cornus kousa Venus.jpg"},
  {"name": "Liquidambar styraciflua", "assetPath": "lib/utils/plants/Liquidambar styraciflua.jpg"},
  {"name": "Magnolia × 'Coral Lake'", "assetPath": "lib/utils/plants/Magnolia × Coral Lake.JPG"},
  {"name": "Magnolia grandiflora 'Kay Parris'", "assetPath": "lib/utils/plants/Magnolia grandiflora Kay Parris.JPG"},
  {"name": "Pinus nigra", "assetPath": "lib/utils/plants/Pinus nigra.jpg"},
  {"name": "Liriodendron tulipifera", "assetPath": "lib/utils/plants/Liriodendron tulipifera.jpg"},
  {"name": "Sequoia sempervirens Winter Blue", "assetPath": "lib/utils/plants/Sequoia sempervirens Winter Blue.jpg"},
  {"name": "Abies koreana 'Kosmos'", "assetPath": "lib/utils/plants/Abies koreana Kosmos.jpg"},
  {"name": "Sequoia sempervirens Xeno", "assetPath": "lib/utils/plants/Sequoia sempervirens Xeno.jpg"},
  {"name": "Abies vejarii 'Mountain Blue'", "assetPath": "lib/utils/plants/Abies vejarii ‘Mountain Blue’.jpg"},
  {"name": "Magnolia denudata 'Yellow River'", "assetPath": "lib/utils/plants/Magnolia denudata ‘Yellow River’.jpg"},
  {"name": "Fagus sylvatica 'Black Swan'", "assetPath": "lib/utils/plants/Fagus sylvatica ‘Black Swan’.jpg"},
  {"name": "Quercus frainetto", "assetPath": "lib/utils/plants/Quercus frainetto.jpg"},
  {"name": "Platanus × acerifolia", "assetPath": "lib/utils/plants/Platanus × acerifolia.jpg"},
];

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  // dynamické pre používateľa
  final List<String> lastCollected = [];
  int foundPlants = 0;

  void _onPlantScanned(String plantName) {
    // ✅ Podmienka: ak rastlina nie je v zozname všetkých 26, ignorujeme kód
    if (!allPlants.any((p) => p["name"] == plantName)) return;

    setState(() {
      // iba ak ešte nebola rastlina naskenovaná
      if (!lastCollected.contains(plantName)) {
        foundPlants++;

        lastCollected.add(plantName);

        // ✅ Zobraziť iba posledné 3 rastliny
        if (lastCollected.length > 3) {
          lastCollected.removeAt(0);
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    final totalPlants = allPlants.length;
    final progress = totalPlants == 0 ? 0.0 : foundPlants / totalPlants;
    final percent = (progress * 100).round();

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

          // 🌿 Scan Button
          GestureDetector(
            onTap: () async {
              final scanned = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (ctx) => ScannerPage(
                    onScan: (code) => handleScan(ctx, code),
                  ),
                ),
              );
              if (scanned != null) _onPlantScanned(scanned);
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
                GradientProgressBar(value: progress, height: 8),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("$foundPlants / $totalPlants",
                        style: TextStyle(fontSize: 13, color: AppTokens.textSecondary)),
                    Text("$percent%",
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
            children: lastCollected.map((name) {
              // 🔍 nájdi rastlinu podľa názvu
              final plant = allPlants.firstWhere(
                    (p) => p["name"] == name,
              );

              return NeonCard(
                color: AppTokens.cardDark,
                shadows: AppTokens.tileShadow,
                radius: AppTokens.radiusMd,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // 🌿 obrázok rastliny
                    Image.asset(
                      plant["assetPath"]!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),

                    const SizedBox(width: 12),

                    // 📛 názov rastliny
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        ],
      ),
    );
  }
}
