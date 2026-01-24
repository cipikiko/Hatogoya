import 'package:flutter/material.dart';

import '../data/plants_data.dart';
import '../lang/strings.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  String? _error;

  int _foundPlants = 0;
  List<int> _lastPlantIds = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('Najprv sa prihlás.');

      final prof = await ApiService.getProfile(token);

      if (!mounted) return;
      setState(() {
        _foundPlants = (prof['foundCount'] as num?)?.toInt() ?? 0;
        _lastPlantIds = List<int>.from(prof['lastPlants'] ?? const []);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    final totalPlants = plants.length; // 26
    final progress = totalPlants == 0 ? 0.0 : (_foundPlants / totalPlants).clamp(0.0, 1.0);

    final recentPlants = _lastPlantIds
        .map((id) => plantById[id])
        .whereType<PlantItem>()
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PulseGlow(
            color: AppTokens.green400,
            child: NeonCard(
              gradient: AppTokens.headerGradient,
              shadows: AppTokens.glow(AppTokens.green400, blur: 18),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.eco, color: Colors.white, size: 28),
                      ),
                      SizedBox(width: 12),
                      _HeaderTitle(),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (_loading)
                    const LinearProgressIndicator(minHeight: 6)
                  else if (_error != null)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  else ...[
                      Text(
                        tr.profilePlantsDiscovered,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(6)),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          tr.profileProgressPlants(_foundPlants, totalPlants),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                ],
              ),
            ),
          ),



          const SizedBox(height: 28),

          Text(
            tr.profileRecentActivity,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator()))
          else if (_error != null)
            Text(_error!, style: TextStyle(color: AppTokens.textSecondary))
          else if (recentPlants.isEmpty)
              Text('Zatiaľ žiadna aktivita.', style: TextStyle(color: AppTokens.textSecondary))
            else
              Column(
                children: recentPlants.map((p) {
                  return _ActivityCard(
                    title: 'Objavená rastlina: ${p.name}',
                    date: 'Recently',
                    color: const Color(0xFF81C784),
                  );
                }).toList(),
              ),
        ],
      ),
    );
  }
}

/* ===== Mini-widgets (nezmenené) ===== */

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.profileTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(tr.profileSubtitle, style: const TextStyle(color: Colors.white70)),
        Text(
          tr.profileMemberSince('September 2025'),
          style: const TextStyle(color: Colors.white60),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      color: AppTokens.cardDark,
      shadows: AppTokens.tileShadow,
      radius: AppTokens.radiusMd,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - 20 * 2 - 12) / 2,
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: AppTokens.tealGradient,
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                boxShadow: AppTokens.glow(AppTokens.green400, blur: 10),
              ),
              child: Center(child: Icon(icon, color: Colors.white, size: 22)),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: AppTokens.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String date;
  final Color color;

  const _ActivityCard({
    required this.title,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      color: AppTokens.cardDark,
      shadows: AppTokens.tileShadow,
      radius: AppTokens.radiusMd,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.30),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: const Icon(Icons.eco, color: AppTokens.emerald500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(color: AppTokens.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
