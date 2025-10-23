import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Challenges',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Complete quests and earn rewards',
              style: TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 25),

          // 🏆 Total Points Card (upravený gradient)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Points',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    SizedBox(height: 4),
                    Text('1,720',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.emoji_events_outlined,
                      color: Colors.white, size: 32),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 🔥 Active Challenges
          const Text('Active Challenges',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),

          const ChallengeCard(
            title: 'Weekly Explorer',
            subtitle: 'Visit the garden 5 times this week',
            xp: '+100 XP',
            progress: 3 / 5,
            daysLeft: '3 days left',
            color: AppColors.primaryGreen,
          ),
          const ChallengeCard(
            title: 'Plant Photographer',
            subtitle: 'Take photos of 10 different plants',
            xp: '+75 XP',
            progress: 7 / 10,
            daysLeft: '5 days left',
            color: AppColors.secondaryGreen,
          ),
          const ChallengeCard(
            title: 'Early Bird',
            subtitle: 'Visit the garden before 9 AM',
            xp: '+50 XP',
            progress: 0 / 1,
            daysLeft: 'Today',
            color: Color(0xFFFFF59D),
          ),

          const SizedBox(height: 30),

          // 🥇 Leaderboard
          const Text('Leaderboard',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),

          const LeaderboardTile(
              position: 1,
              name: 'Sarah M.',
              points: 2450,
              highlightColor: Color(0xFFFFF59D)),
          const LeaderboardTile(
              position: 2,
              name: 'John D.',
              points: 2180,
              highlightColor: Color(0xFFB2DFDB)),
          const LeaderboardTile(
              position: 3,
              name: 'Emma L.',
              points: 1950,
              highlightColor: Color(0xFFFFCCBC)),
          const LeaderboardTile(
              position: 4,
              name: 'You',
              points: 1720,
              highlightColor: Color(0xFFC8E6C9),
              isUser: true),
          const LeaderboardTile(
              position: 5,
              name: 'Mike R.',
              points: 1650,
              highlightColor: Color(0xFFF5F5F5)),

          const SizedBox(height: 30),

          // ✅ Recently Completed
          const Text('Recently Completed',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),

          const CompletedCard(
            title: 'First Steps',
            subtitle: 'Discover your first plant',
            xp: '+25 XP',
            date: 'Oct 14, 2025',
          ),
          const CompletedCard(
            title: 'Plant Enthusiast',
            subtitle: 'Discover 25 different plants',
            xp: '+150 XP',
            date: 'Oct 13, 2025',
          ),
        ],
      ),
    );
  }
}

// 🎯 Challenge Card
class ChallengeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String xp;
  final double progress;
  final String daysLeft;
  final Color color;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.progress,
    required this.daysLeft,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    xp,
                    style: TextStyle(
                        color: color.darken(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: color,
              minHeight: 5,
            ),
            const SizedBox(height: 6),
            Text(daysLeft,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

// 🏅 Leaderboard Tile (upravené s trofejami)
class LeaderboardTile extends StatelessWidget {
  final int position;
  final String name;
  final int points;
  final Color highlightColor;
  final bool isUser;

  const LeaderboardTile({
    super.key,
    required this.position,
    required this.name,
    required this.points,
    required this.highlightColor,
    this.isUser = false,
  });

  IconData? _getTrophyIcon() {
    if (position <= 3) return Icons.emoji_events;
    return null;
  }

  Color _getTrophyColor() {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // zlatá
      case 2:
        return const Color(0xFFC0C0C0); // strieborná
      case 3:
        return const Color(0xFFCD7F32); // bronzová
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: highlightColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text('$position',
              style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        ),
        title: Row(
          children: [
            Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isUser ? AppColors.primaryGreen : Colors.black)),
            if (position <= 3) ...[
              const SizedBox(width: 6),
              Icon(_getTrophyIcon(), color: _getTrophyColor(), size: 18),
            ],
          ],
        ),
        subtitle: Text('$points points',
            style: const TextStyle(color: Colors.black54, fontSize: 13)),
      ),
    );
  }
}

// ✅ Completed Challenge Card
class CompletedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String xp;
  final String date;

  const CompletedCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 4),
                Text(date,
                    style: const TextStyle(color: Colors.black45, fontSize: 11)),
              ],
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(xp,
                  style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

// 🌈 Helper na stmavenie farby
extension ColorShade on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
