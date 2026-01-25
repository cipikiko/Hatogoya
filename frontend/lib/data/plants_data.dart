/// Single source of truth for the 26 plants used in the app UI.
/// IDs must match DB `plants.id`.

class PlantItem {
  final int id; // 1..26
  final String name;
  final String assetPath;

  const PlantItem({
    required this.id,
    required this.name,
    required this.assetPath,
  });
}

const List<PlantItem> plants = [
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

final Map<int, PlantItem> plantById = {
  for (final p in plants) p.id: p,
};
