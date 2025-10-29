import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Challenges', style: AppTokens.h1),
          const SizedBox(height: 4),
          const Text('Complete quests and earn rewards', style: AppTokens.body),
          const SizedBox(height: 25),

          // 🏆 Total Points – teal gradient NeonCard
          NeonCard(
            gradient: AppTokens.tealGradient,
            shadows: AppTokens.glow(AppTokens.teal400, blur: 18),
            radius: AppTokens.radiusMd,
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Points', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    SizedBox(height: 4),
                    Text('1,720',
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events_outlined, color: Colors.white, size: 32),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 🔥 Active Challenges
          const Text('Active Challenges',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTokens.textPrimary)),
          const SizedBox(height: 10),

          const _ChallengeCard(
            title: 'Weekly Explorer',
            subtitle: 'Visit the garden 5 times this week',
            xp: '+100 XP',
            progress: 3 / 5,
            daysLeft: '3 days left',
          ),
          const _ChallengeCard(
            title: 'Plant Photographer',
            subtitle: 'Take photos of 10 different plants',
            xp: '+75 XP',
            progress: 7 / 10,
            daysLeft: '5 days left',
          ),
          const _ChallengeCard(
            title: 'Early Bird',
            subtitle: 'Visit the garden before 9 AM',
            xp: '+50 XP',
            progress: 0 / 1,
            daysLeft: 'Today',
          ),

          const SizedBox(height: 30),

          // 🥇 Leaderboard
          const Text('Leaderboard',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTokens.textPrimary)),
          const SizedBox(height: 10),

          const _LeaderboardTile(position: 1, name: 'Sarah M.', points: 2450),
          const _LeaderboardTile(position: 2, name: 'John D.', points: 2180),
          const _LeaderboardTile(position: 3, name: 'Emma L.', points: 1950),
          const _LeaderboardTile(position: 4, name: 'You', points: 1720, isUser: true),
          const _LeaderboardTile(position: 5, name: 'Mike R.', points: 1650),

          const SizedBox(height: 30),

          // ✅ Recently Completed
          const Text('Recently Completed',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTokens.textPrimary)),
          const SizedBox(height: 10),

          const _CompletedCard(
            title: 'First Steps',
            subtitle: 'Discover your first plant',
            xp: '+25 XP',
            date: 'Oct 14, 2025',
          ),
          const _CompletedCard(
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

/* -------------------- Widgets -------------------- */

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String xp;
  final double progress;
  final String daysLeft;

  const _ChallengeCard({
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.progress,
    required this.daysLeft,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      color: AppTokens.cardDark,
      shadows: AppTokens.tileShadow,
      radius: AppTokens.radiusMd,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header: názov + XP chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                    color: AppTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  )),
              NeonChip(xp),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTokens.textSecondary)),
          const SizedBox(height: 10),

          // progress bar (emerald → cyan)
          GradientProgressBar(value: progress.clamp(0, 1), height: 6),
          const SizedBox(height: 6),

          Text(daysLeft, style: const TextStyle(fontSize: 12, color: AppTokens.textSecondary)),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int position;
  final String name;
  final int points;
  final bool isUser;

  const _LeaderboardTile({
    required this.position,
    required this.name,
    required this.points,
    this.isUser = false,
  });

  IconData? _trophyIcon() => position <= 3 ? Icons.emoji_events : null;

  Color _trophyColor() {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // gold
      case 2:
        return const Color(0xFFC0C0C0); // silver
      case 3:
        return const Color(0xFFCD7F32); // bronze
      default:
        return AppTokens.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      color: AppTokens.cardDark,
      shadows: AppTokens.tileShadow,
      radius: AppTokens.radiusSm,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          // pozícia
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTokens.cardDark,
            child: Text(
              '$position',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTokens.textPrimary),
            ),
          ),
          const SizedBox(width: 10),

          // meno + trofej
          Expanded(
            child: Row(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isUser ? AppTokens.emerald500 : AppTokens.textPrimary,
                  ),
                ),
                if (_trophyIcon() != null) ...[
                  const SizedBox(width: 6),
                  Icon(_trophyIcon(), color: _trophyColor(), size: 18),
                ],
              ],
            ),
          ),

          // body
          Text('$points pts', style: const TextStyle(color: AppTokens.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String xp;
  final String date;

  const _CompletedCard({
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      color: AppTokens.cardDark,
      shadows: AppTokens.tileShadow,
      radius: AppTokens.radiusMd,
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // texty
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    color: AppTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  )),
              Text(subtitle, style: const TextStyle(color: AppTokens.textSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: AppTokens.textSecondary, fontSize: 11)),
            ],
          ),
          // XP chip (žltý)
          NeonChip(xp),
        ],
      ),
    );
  }
}

/* -------- Helpers -------- */

extension ColorShade on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
