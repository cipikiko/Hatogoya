import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back, Explorer!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Continue your botanical journey',
            style: TextStyle(fontSize: 15, color: AppColors.textGrey),
          ),
          const SizedBox(height: 25),

          // 🌿 Gradient Level Card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.eco, color: Colors.white, size: 22),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level 8',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Plant Explorer',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '340 / 500 XP',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 340 / 500,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 6,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 📊 Stats Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _StatCard(
                icon: Icons.local_fire_department,
                iconColor: Color(0xFFFFA726),
                value: '12',
                label: 'Day Streak',
              ),
              _StatCard(
                icon: Icons.eco,
                iconColor: Color(0xFF66BB6A),
                value: '47',
                label: 'Plants',
              ),
              _StatCard(
                icon: Icons.workspace_premium_rounded,
                iconColor: Color(0xFFBA68C8),
                value: '23',
                label: 'Badges',
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 🪴 Daily Quest
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 3))
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Daily Quest',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        '+50 XP',
                        style: TextStyle(
                            color: AppColors.accentYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Discover 3 New Plants',
                    style: TextStyle(color: Colors.black87)),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 1 / 3,
                  backgroundColor: Colors.grey[300],
                  color: AppColors.primaryGreen,
                  minHeight: 5,
                ),
                const SizedBox(height: 4),
                const Align(
                    alignment: Alignment.centerRight,
                    child: Text('Progress 1/3',
                        style:
                        TextStyle(color: Colors.black54, fontSize: 12))),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Recent Achievements',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),

          const _AchievementCard(
            title: 'Early Bird',
            subtitle: 'Unlocked today',
            icon: Icons.wb_sunny_outlined,
            color: Color(0xFFFFCC80),
          ),
          const _AchievementCard(
            title: 'Plant Expert',
            subtitle: 'Unlocked today',
            icon: Icons.grass_rounded,
            color: Color(0xFFA5D6A7),
          ),
          const _AchievementCard(
            title: 'Week Warrior',
            subtitle: 'Unlocked today',
            icon: Icons.flash_on_outlined,
            color: Color(0xFFFFF59D),
          ),
          const ExploreGardenCard(), // 🌿 Nová klikateľná karta
        ],
      ),
    );
  }
}

// 📊 Komponenty
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _AchievementCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: color.withValues(alpha: 0.5),
          child: Icon(icon, color: AppColors.primaryGreen),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

// 🌿 Klikateľná karta "Explore the Garden"
class ExploreGardenCard extends StatelessWidget {
  const ExploreGardenCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const GardenMapDialog(),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFE0F7FA), // modrastá
              Color(0xFFE8F5E9), // zelenkastá
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: AppColors.primaryGreen, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Explore the Garden',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Visit new areas and discover plants',
                    style: TextStyle(color: AppColors.textGrey),
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

// 🗺️ Dialóg s mapou záhrady
class GardenMapDialog extends StatelessWidget {
  const GardenMapDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Garden Map',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Explore different zones and discover new plants',
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 20),

            // 🟢 Placeholder pre mapu
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: const Center(
                child: Icon(Icons.map_outlined,
                    size: 80, color: AppColors.primaryGreen),
              ),
            ),

            const SizedBox(height: 20),

            // 🪴 Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.circle, color: AppColors.primaryGreen, size: 12),
                SizedBox(width: 5),
                Text('Discovered', style: TextStyle(fontSize: 13)),
                SizedBox(width: 15),
                Icon(Icons.circle, color: Colors.grey, size: 12),
                SizedBox(width: 5),
                Text('Locked', style: TextStyle(fontSize: 13)),
              ],
            ),

            const SizedBox(height: 20),

            // 🧭 Tlačidlá
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Tour'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
