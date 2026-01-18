// lib/game/assets/assets.dart
import 'dart:ui' show Offset;

import 'package:latlong2/latlong.dart';
import '../plant_dialog.dart';

/// ===============================
/// BODY RASTLÍN (GPS POZÍCIE)
/// ===============================
const List<LatLng> plantPoints = [
  LatLng(51.227659, 5.878646), // 1
  LatLng(51.227607, 5.878581), // 2
  LatLng(51.227526, 5.878704), // 3
  LatLng(51.227485, 5.878560), // 4
  LatLng(51.227332, 5.878066), // 5
  LatLng(51.227420, 5.878122), // 6
  LatLng(51.227514, 5.878045), // 7
  LatLng(51.227563, 5.878024), // 8
  LatLng(51.227661, 5.877970), // 9
  LatLng(51.227332, 5.877538), // 10
  LatLng(51.227256, 5.877768), // 11
  LatLng(51.226931, 5.877571), // 12
  LatLng(51.226928, 5.877351), // 13
  LatLng(51.227012, 5.877274), // 14
  LatLng(51.226835, 5.877004), // 15
  LatLng(51.226732, 5.876960), // 16
  LatLng(51.226905, 5.876904), // 17
  LatLng(51.226940, 5.876684), // 18
  LatLng(51.227025, 5.876734), // 19
  LatLng(51.227019, 5.876840), // 20
  LatLng(51.227087, 5.876828), // 21
  LatLng(51.227100, 5.876619), // 22
  LatLng(51.227099, 5.876708), // 23
  LatLng(51.227266, 5.876771), // 24
  LatLng(51.227406, 5.876712), // 25
  LatLng(51.227361, 5.877025), // 26
];

/// ===============================
/// RASTLINY
/// ===============================
const List<PlantItem> plants = [
  PlantItem(id: 1, name: "Cornus controversa 'Variegata'", assetPath: "lib/utils/plants/Cornus controversa.jpg"),
  PlantItem(id: 2, name: "Sciadopitys verticillata 'Wiel's Beauty'", assetPath: "lib/utils/plants/Sciadopitys verticillata Wiel’s Beauty.jpg"),
  PlantItem(id: 3, name: "Cedrus atlantica 'Glauca'", assetPath: "lib/utils/plants/Cedrus atlantica Glauca.jpg"),
  PlantItem(id: 4, name: "Camellia japonica", assetPath: "lib/utils/plants/Camellia japonica.jpg"),
  PlantItem(id: 5, name: "Ginkgo biloba 'China Pendula'", assetPath: "lib/utils/plants/Ginkgo biloba China Pendula.jpg"),
  PlantItem(id: 6, name: "Acer japonica 'Orange Dream'", assetPath: "lib/utils/plants/Acer japonica Orange Dream.jpg"),
  PlantItem(id: 7, name: "Ginkgo biloba 'Mariken'", assetPath: "lib/utils/plants/Ginkgo biloba Mariken.jpg"),
  PlantItem(id: 8, name: "Cedrus deodara 'Aurea'", assetPath: "lib/utils/plants/Cedrus deodara Aurea.jpg"),
  PlantItem(id: 9, name: "Cedrus atlantica 'Glauca Pendula'", assetPath: "lib/utils/plants/Cedrus atlantica Glauca Pendula.jpg"),
  PlantItem(id: 10, name: "Sequoiadendron giganteum", assetPath: "lib/utils/plants/Sequoiadendron giganteum.jpg"),
  PlantItem(id: 11, name: "Sequoia sempervirens 'Loma Prieta Spike'", assetPath: "lib/utils/plants/Sequoia sempervirens Loma Prieta Spike.jpg"),
  PlantItem(id: 12, name: "Pinus sabiniana 'Isabella'", assetPath: "lib/utils/plants/Pinus sabiniana Isabella.JPG"),
  PlantItem(id: 13, name: "Cornus × venus", assetPath: "lib/utils/plants/Cornus kousa Venus.jpg"),
  PlantItem(id: 14, name: "Liquidambar styraciflua", assetPath: "lib/utils/plants/Liquidambar styraciflua.jpg"),
  PlantItem(id: 15, name: "Magnolia × 'Coral Lake'", assetPath: "lib/utils/plants/Magnolia × Coral Lake.JPG"),
  PlantItem(id: 16, name: "Magnolia grandiflora 'Kay Parris'", assetPath: "lib/utils/plants/Magnolia grandiflora Kay Parris.JPG"),
  PlantItem(id: 17, name: "Pinus nigra", assetPath: "lib/utils/plants/Pinus nigra.jpg"),
  PlantItem(id: 18, name: "Liriodendron tulipifera", assetPath: "lib/utils/plants/Liriodendron tulipifera.jpg"),
  PlantItem(id: 19, name: "Sequoia sempervirens Winter Blue", assetPath: "lib/utils/plants/Sequoia sempervirens Winter Blue.jpg"),
  PlantItem(id: 20, name: "Abies koreana 'Kosmos'", assetPath: "lib/utils/plants/Abies koreana Kosmos.jpg"),
  PlantItem(id: 21, name: "Sequoia sempervirens Xeno", assetPath: "lib/utils/plants/Sequoia sempervirens Xeno.jpg"),
  PlantItem(id: 22, name: "Abies vejarii 'Mountain Blue'", assetPath: "lib/utils/plants/Abies vejarii ‘Mountain Blue’.jpg"),
  PlantItem(id: 23, name: "Magnolia denudata 'Yellow River'", assetPath: "lib/utils/plants/Magnolia denudata ‘Yellow River’.jpg"),
  PlantItem(id: 24, name: "Fagus sylvatica 'Black Swan'", assetPath: "lib/utils/plants/Fagus sylvatica ‘Black Swan’.jpg"),
  PlantItem(id: 25, name: "Quercus frainetto", assetPath: "lib/utils/plants/Quercus frainetto.jpg"),
  PlantItem(id: 26, name: "Platanus × acerifolia", assetPath: "lib/utils/plants/Platanus × acerifolia.jpg"),
];

/// ===============================
/// MAP IMAGE
/// ===============================
const String mapImageAsset = 'lib/game/assets/map.png';
const double mapWidthPx = 1167;
const double mapHeightPx = 1653;

/// ===============================
/// GPS -> PIXEL TRANSFORM (FIXNÝ)
/// ===============================
/// x = a*lng + b*lat + c
/// y = d*lng + e*lat + f
class Affine2D {
  final double a, b, c, d, e, f;
  const Affine2D(this.a, this.b, this.c, this.d, this.e, this.f);

  Offset gpsToPixel(LatLng p) {
    final lat = p.latitude;
    final lng = p.longitude;
    final x = a * lng + b * lat + c;
    final y = d * lng + e * lat + f;
    return Offset(x, y);
  }
}

const Affine2D gpsToPx = Affine2D(
  -172060.812990458,
  730209.7406877925,
  -36394876.27033414,
  415949.7106096346,
  299198.3442375831,
  -17770951.063184246,
);

/// ===============================
/// PIXEL DOLADENIE MARKEROV
/// ===============================
const List<Offset> markerOffsetsPx = [
  Offset(-10, 5), // 1
  Offset(3, 2), // 2
  Offset(-4, -8), // 3
  Offset(-10, -5), // 4
  Offset(35, 100), // 5
  Offset(10.2, 27.1), // 6
  Offset(14.0, 39.9), // 7
  Offset(10, 7), // 8
  Offset(-18.3, -22.6), // 9
  Offset(10, -5), // 10
  Offset(-5, -15), // 11
  Offset(29.4, -23.4), // 12
  Offset(-4, 5), // 13
  Offset(10, -4), // 14
  Offset(-20, 30), // 15
  Offset(-10, -10), // 16
  Offset(0, 0), // 17
  Offset(0, 0), // 18
  Offset(-10, -10), // 19
  Offset(-5, -8), // 20
  Offset(0, 0), // 21
  Offset(-33.8, -11.4), // 22
  Offset(0, 0), // 23
  Offset(0, 0), // 24
  Offset(0, 0), // 25
  Offset(15, -10), // 26
];
