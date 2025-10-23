import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final filteredPlants = _plants
        .where((p) =>
    p['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p['latin'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Plants',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Browse, search, and explore discovered plants',
                style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 20),

            // 🔍 Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
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

            // 🪴 List of plants
            Column(
              children: filteredPlants.map((plant) {
                final bool found = plant['found'];
                return Opacity(
                  opacity: found ? 1.0 : 0.5,
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: found
                              ? AppColors.primaryGreen.withValues(alpha: 0.15)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.eco_outlined,
                          color: found
                              ? AppColors.primaryGreen
                              : Colors.grey[500],
                        ),
                      ),
                      title: Text(plant['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: found
                                  ? Colors.black
                                  : Colors.black.withValues(alpha: 0.7))),
                      subtitle: Text(plant['latin'],
                          style: const TextStyle(
                              fontStyle: FontStyle.italic, color: Colors.black54)),
                      onTap: found
                          ? () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Opened details for ${plant['name']}'),
                          duration: const Duration(seconds: 1),
                        ));
                      }
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
