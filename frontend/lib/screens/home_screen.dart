import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      padding: EdgeInsets.only(top: topPad, bottom: 24), // bez bočných okrajov hore
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========= Level Card – edge to edge, prilepená na status bar =========
          PulseGlow(
            color: AppTokens.green400,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTokens.tealGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: const [
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                            child: Center(
                              child: BounceGentle(
                                child: Icon(Icons.eco, color: Colors.white, size: 28),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        _LevelInfo(),
                      ]),
                      const _XpPill(current: 340, total: 500),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    child: LinearProgressIndicator(
                      value: 340 / 500,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 26),

          // ========= Stat Tiles =========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _StatTile(
                  gradient: AppTokens.statOrange,
                  shadowSeed: AppTokens.orange,
                  icon: Icons.local_fire_department,
                  number: '12',
                  label: 'Day Streak',
                  numberColor: AppTokens.textPrimary,
                  labelColor: AppTokens.textSecondary,
                ),
                _StatTile(
                  gradient: AppTokens.statGreen,
                  shadowSeed: AppTokens.emerald500,
                  icon: Icons.eco,
                  number: '47',
                  label: 'Plants',
                  numberColor: AppTokens.textPrimary,
                  labelColor: AppTokens.textSecondary,
                ),
                _StatTile(
                  gradient: AppTokens.statPurple,
                  shadowSeed: AppTokens.purple,
                  icon: Icons.workspace_premium_rounded,
                  number: '23',
                  label: 'Badges',
                  numberColor: AppTokens.textPrimary,
                  labelColor: AppTokens.textSecondary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // ========= Daily Quest =========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: NeonCard(
              color: AppTokens.cardDark,
              shadows: AppTokens.tileShadow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _RowTitle(),
                  SizedBox(height: 8),
                  Text('Discover 3 New Plants', style: AppTokens.body),
                  SizedBox(height: 12),
                  Text('Progress', style: TextStyle(color: AppTokens.textSecondary, fontSize: 12)),
                  SizedBox(height: 6),
                  GradientProgressBar(value: 1 / 3),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // ========= Recent Achievements =========
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _SectionTitle(title: 'Recent Achievements'),
          ),
          const SizedBox(height: 10),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _AchievementCard(
                  title: 'Early Bird',
                  subtitle: 'Unlocked today',
                  colorBlob: LinearGradient(
                    colors: [Color(0xFFFFA94D), Color(0xFFFF6B6B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  icon: Icons.wb_sunny_outlined,
                ),
                SizedBox(height: 12),
                _AchievementCard(
                  title: 'Plant Expert',
                  subtitle: 'Unlocked today',
                  colorBlob: LinearGradient(
                    colors: [Color(0xFF34D399), Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  icon: Icons.grass_rounded,
                ),
                SizedBox(height: 12),
                _AchievementCard(
                  title: 'Week Warrior',
                  subtitle: 'Unlocked today',
                  colorBlob: LinearGradient(
                    colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  icon: Icons.flash_on_outlined,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ========= Explore the Garden =========
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                showDialog(context: context, builder: (_) => const GardenMapDialog());
              },
              child: NeonCard(
                gradient: AppTokens.tealGradient,
                shadows: AppTokens.glow(AppTokens.green600, blur: 14),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: const [
                    Icon(Icons.location_on_outlined, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('Explore the Garden', style: AppTokens.titleWhite),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================== Mini-widgets ================== */

class _LevelInfo extends StatelessWidget {
  const _LevelInfo();
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('Level 8', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          SizedBox(width: 6),
        ]),
        Text('Plant Explorer', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _XpPill extends StatelessWidget {
  final int current, total;
  const _XpPill({required this.current, required this.total});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('$current', style: const TextStyle(color: Colors.white, fontSize: 22)),
          const SizedBox(height: 2),
          Text('/ $total XP', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RowTitle extends StatelessWidget {
  const _RowTitle();
  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      Text('Daily Quest', style: AppTokens.h1),
      SizedBox(width: 8),
      NeonChip('+50 XP'),
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTokens.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final LinearGradient colorBlob;
  final IconData icon;

  const _AchievementCard({
    required this.title,
    required this.subtitle,
    required this.colorBlob,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      color: AppTokens.cardDark,
      shadows: AppTokens.tileShadow,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: colorBlob,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              boxShadow: AppTokens.tileShadow,
            ),
            child: const Center(child: Icon(Icons.circle, size: 0)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
                  ),
                  const Icon(Icons.star, size: 16, color: Color(0xFFFDE68A)),
                ]),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTokens.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final LinearGradient Function() gradient;
  final Color shadowSeed;
  final IconData icon;
  final String number;
  final String label;
  final Color numberColor;
  final Color labelColor;

  const _StatTile({
    required this.gradient,
    required this.shadowSeed,
    required this.icon,
    required this.number,
    required this.label,
    required this.numberColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      decoration: BoxDecoration(
        color: AppTokens.cardDark,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: AppTokens.cardBorder),
        boxShadow: AppTokens.glow(shadowSeed, blur: 12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: gradient(),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              boxShadow: AppTokens.glow(shadowSeed, blur: 10),
            ),
            child: Center(child: BounceGentle(child: Icon(icon, color: Colors.white, size: 22))),
          ),
          const SizedBox(height: 8),
          Text(number, style: TextStyle(color: numberColor, fontWeight: FontWeight.w700, fontSize: 18)),
          Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
          const SizedBox(height: 0),
        ],
      ),
    );
  }
}

/* ============== Garden Map Dialog (svetlý pastel tyrkys-modrý) ============== */

class GardenMapDialog extends StatelessWidget {
  const GardenMapDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(18),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE9FFF7), Color(0xFFE6F4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Garden Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                const Text('Explore different zones and discover new plants',
                    style: TextStyle(color: Color(0xFF047857))),
                const SizedBox(height: 14),
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    border: Border.all(color: AppTokens.emerald500, width: 1),
                  ),
                  child: const Center(child: Icon(Icons.map_outlined, size: 84, color: AppTokens.green600)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE2F7F1), width: 1),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.touch_app_outlined, color: AppTokens.green600, size: 18),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text('Tap a location to view details',
                            style: TextStyle(color: Color(0xFF047857), fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Icon(Icons.circle, color: AppTokens.emerald500, size: 12),
                    SizedBox(width: 6),
                    Text('Discovered', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 16),
                    Icon(Icons.circle, color: Colors.grey, size: 12),
                    SizedBox(width: 6),
                    Text('Locked', style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTokens.green600,
                        side: const BorderSide(color: AppTokens.green600),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Tour'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTokens.green600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
