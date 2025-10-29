import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';

class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

class _PlantsScreenState extends State<PlantsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _plants = [
    {'name': 'Monstera Deliciosa', 'latin': 'Monstera deliciosa', 'found': true},
    {'name': 'Succulent Collection', 'latin': 'Various succulents', 'found': true},
    {'name': 'Garden Flowers', 'latin': 'Mixed varieties', 'found': true},
    {'name': 'Aloe Vera', 'latin': 'Aloe barbadensis', 'found': false},
    {'name': 'Peace Lily', 'latin': 'Spathiphyllum wallisii', 'found': false},
    {'name': 'Snake Plant', 'latin': 'Dracaena trifasciata', 'found': true},
    {'name': 'Cactus', 'latin': 'Cactaceae species', 'found': true},
    {'name': 'Bamboo Palm', 'latin': 'Chamaedorea seifrizii', 'found': false},
    {'name': 'Orchid', 'latin': 'Orchidaceae', 'found': true},
    {'name': 'Fiddle Leaf Fig', 'latin': 'Ficus lyrata', 'found': false},
  ];

  String _searchQuery = '';
  /// kra kra kra

  @override
  Widget build(BuildContext context) {
    final filteredPlants = _plants
        .where((p) =>
    p['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p['latin'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'All Plants',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Browse, search, and explore discovered plants',
            style: AppTokens.body,
          ),
          const SizedBox(height: 20),

          // 🔍 Search Bar (dark + tokens)
          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppTokens.textPrimary),
            onChanged: (value) => setState(() => _searchQuery = value),
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

          // 🪴 List of plants
          Column(
            children: filteredPlants.map((plant) {
              final bool found = plant['found'] as bool;

              return Opacity(
                opacity: found ? 1.0 : 0.7,
                child: NeonCard(
                  color: AppTokens.cardDark,
                  shadows: AppTokens.tileShadow,
                  radius: AppTokens.radiusMd,
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    onTap: found
                        ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          Text('Opened details for ${plant['name']}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                        : null,
                    child: Row(
                      children: [
                        // leading box – zelený gradient ak found, inak tlmený box
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: found ? AppTokens.statGreen() : null,
                            color: found ? null : AppTokens.cardDark,
                            borderRadius:
                            BorderRadius.circular(AppTokens.radiusSm),
                            border: Border.all(
                                color: found
                                    ? Colors.transparent
                                    : AppTokens.cardBorder),
                            boxShadow: found
                                ? AppTokens.glow(AppTokens.emerald500, blur: 10)
                                : null,
                          ),
                          child: Icon(
                            Icons.eco_outlined,
                            color:
                            Colors.white.withValues(alpha: found ? 1 : 0.6),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // titles
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plant['name'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppTokens.textPrimary,
                                ),
                              ),
                              Text(
                                plant['latin'] as String,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: AppTokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: (found
                                ? AppTokens.emerald500
                                : Colors.grey)
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            found ? 'Discovered' : 'Locked',
                            style: TextStyle(
                              color: found
                                  ? AppTokens.emerald500
                                  : Colors.grey[400],
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
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
