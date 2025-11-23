import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openSubmitPlantDialog() {
    showDialog(
      context: context,
      builder: (context) => const SubmitPlantDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (gradient + progress)
          PulseGlow(
            color: AppTokens.green400,
            child: NeonCard(
              gradient: AppTokens.headerGradient,
              shadows: AppTokens.glow(AppTokens.green400, blur: 18),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.eco, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 12),
                    _HeaderTitle(),
                  ]),
                  const SizedBox(height: 12),
                  const Text('Level 8',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 6),
                  const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    child: LinearProgressIndicator(
                      value: 1720 / 2000,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('1720 / 2000 XP',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),
          // Stats (2 + 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _StatBox(label: 'Total Visits', value: '32', icon: Icons.place),
              _StatBox(label: 'Plants Found', value: '47', icon: Icons.eco),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _StatBox(label: 'Badges Earned', value: '23', icon: Icons.star),
              _StatBox(label: 'Current Streak', value: '12', icon: Icons.local_fire_department),
            ],
          ),

          const SizedBox(height: 28),

          const Text('Achievements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTokens.textPrimary)),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 24,
            crossAxisSpacing: 10,
            childAspectRatio: 0.9,
            children: const [
              _AchievementIcon(label: 'First Discovery', icon: Icons.spa,   color: Color(0xFFA5D6A7)),
              _AchievementIcon(label: 'Plant Expert',    icon: Icons.eco,   color: Color(0xFF81C784)),
              _AchievementIcon(label: 'Early Bird',      icon: Icons.wb_sunny_outlined, color: Color(0xFFFFF59D)),
              _AchievementIcon(label: 'Week Warrior',    icon: Icons.flash_on,          color: Color(0xFFFFE082)),
              _AchievementIcon(label: 'Photographer',    icon: Icons.camera_alt,        color: Color(0xFF90CAF9), locked: true),
              _AchievementIcon(label: 'Collection Master', icon: Icons.collections_bookmark, color: Color(0xFFB39DDB), locked: true),
              _AchievementIcon(label: 'Rare Hunter',     icon: Icons.search,            color: Color(0xFF80CBC4), locked: true),
              _AchievementIcon(label: 'Garden Guardian', icon: Icons.shield_moon,       color: Color(0xFFB0BEC5), locked: true),
            ],
          ),

          const SizedBox(height: 28),

          const Text('Recent Activity',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTokens.textPrimary)),
          const SizedBox(height: 10),

          const _ActivityCard(
            title: 'Discovered Monstera Deliciosa',
            date: 'Oct 15, 2025',
            color: Color(0xFFA5D6A7),
          ),
          const _ActivityCard(
            title: 'Completed Weekly Explorer Challenge',
            date: 'Oct 14, 2025',
            color: Color(0xFFB39DDB),
          ),
          const _ActivityCard(
            title: 'Discovered Succulent Garden',
            date: 'Oct 13, 2025',
            color: Color(0xFF81C784),
          ),

          // Submit a Plant (banner-like CTA)
          GestureDetector(
            onTap: _openSubmitPlantDialog,
            child: NeonCard(
              color: AppTokens.cardDark,
              shadows: AppTokens.glow(AppTokens.green400, blur: 12),
              radius: AppTokens.radiusMd,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: const [
                  Icon(Icons.upload_rounded, color: AppTokens.emerald500),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Submit a Plant\nShare your discovery with the community',
                      style: TextStyle(color: AppTokens.textPrimary, height: 1.25, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppTokens.textSecondary, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===== Mini-widgets ===== */

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plant Explorer',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text('Botanical Enthusiast', style: TextStyle(color: Colors.white70)),
        Text('Member since September 2025', style: TextStyle(color: Colors.white60)),
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
              style: const TextStyle(
                color: AppTokens.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool locked;

  const _AchievementIcon({
    required this.label,
    required this.icon,
    required this.color,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconBg = locked ? Colors.grey.withValues(alpha: 0.2) : color.withValues(alpha: 0.45);
    final iconColor = locked ? Colors.grey.withValues(alpha: 0.7) : AppTokens.emerald500;

    return AnimatedOpacity(
      opacity: locked ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 350),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              border: Border.all(color: locked ? AppTokens.cardBorder : Colors.transparent),
              boxShadow: locked ? [] : AppTokens.glow(AppTokens.green400, blur: 10),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: locked ? AppTokens.textSecondary : AppTokens.textPrimary,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
                Text(title,
                    style: const TextStyle(color: AppTokens.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(color: AppTokens.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ===== Submit Plant Dialog ===== */

class SubmitPlantDialog extends StatelessWidget {
  const SubmitPlantDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController scientificController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTokens.panelGradient(),
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: AppTokens.cardBorder),
          boxShadow: AppTokens.tileShadow,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Submit a Plant',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTokens.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Share your plant discovery with the community', style: AppTokens.body),
                  const SizedBox(height: 12),

                  // image drop
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppTokens.cardDark,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      border: Border.all(color: AppTokens.cardBorder),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined, size: 40, color: AppTokens.textSecondary),
                          SizedBox(height: 6),
                          Text('Click to upload photo', style: AppTokens.body),
                          Text('PNG, JPG up to 10MB',
                              style: TextStyle(color: AppTokens.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  _inputField('Plant Name', 'e.g. Monstera Deliciosa', nameController),
                  _inputField('Scientific Name (Optional)', 'e.g. Monstera deliciosa', scientificController),
                  _inputField('Location in Garden', 'e.g. Tropical Zone A', locationController),
                  _inputField('Description (Optional)', 'Tell us about this plant...', descriptionController, maxLines: 3),

                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTokens.cardDark,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      border: Border.all(color: AppTokens.cardBorder),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTokens.emerald500),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your submission will be reviewed by our team before being added to the garden database.',
                            style: AppTokens.body,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.upload, size: 18),
                        label: const Text('Submit Plant'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.green600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: AppTokens.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(color: AppTokens.textSecondary),
          labelStyle: const TextStyle(color: AppTokens.textSecondary),
          filled: true,
          fillColor: AppTokens.cardDark,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            borderSide: const BorderSide(color: AppTokens.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            borderSide: const BorderSide(color: AppTokens.emerald500),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
