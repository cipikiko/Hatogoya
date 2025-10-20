import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

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
          const Text('Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Your botanical journey',
              style: TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 25),

          // 🟢 Profile Header Card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(18),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.eco, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Plant Explorer',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                        Text('Botanical Enthusiast',
                            style: TextStyle(color: Colors.white70)),
                        Text('Member since September 2025',
                            style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text('Level 8',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: 1720 / 2000,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 6,
                ),
                SizedBox(height: 6),
                Align(
                    alignment: Alignment.centerRight,
                    child: Text('1720 / 2000 XP',
                        style: TextStyle(color: Colors.white, fontSize: 13))),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // 📊 Stats Cards
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
              _StatBox(
                  label: 'Current Streak',
                  value: '12',
                  icon: Icons.local_fire_department),
            ],
          ),

          const SizedBox(height: 30),

          // 🏅 Achievements
          const Text('Achievements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),

          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 32,
            crossAxisSpacing: 10,
            childAspectRatio: 0.88,
            children: const [
              _AchievementIcon(label: 'First Discovery', icon: Icons.spa, color: Color(0xFFA5D6A7)),
              _AchievementIcon(label: 'Plant Expert', icon: Icons.eco, color: Color(0xFF81C784)),
              _AchievementIcon(label: 'Early Bird', icon: Icons.wb_sunny_outlined, color: Color(0xFFFFF59D)),
              _AchievementIcon(label: 'Week Warrior', icon: Icons.flash_on, color: Color(0xFFFFE082)),
              _AchievementIcon(label: 'Photographer', icon: Icons.camera_alt, color: Color(0xFF90CAF9), locked: true),
              _AchievementIcon(label: 'Collection Master', icon: Icons.collections_bookmark, color: Color(0xFFB39DDB), locked: true),
              _AchievementIcon(label: 'Rare Hunter', icon: Icons.search, color: Color(0xFF80CBC4), locked: true),
              _AchievementIcon(label: 'Garden Guardian', icon: Icons.shield_moon, color: Color(0xFFB0BEC5), locked: true),
            ],
          ),

          const SizedBox(height: 30),

          // 🕓 Recent Activity
          const Text('Recent Activity',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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

          GestureDetector(
            onTap: _openSubmitPlantDialog,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFDFFFE0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: const [
                  Icon(Icons.upload_rounded, color: AppColors.primaryGreen),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Submit a Plant\nShare your discovery with the community',
                      style: TextStyle(
                          color: Colors.black87,
                          height: 1.3,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.primaryGreen, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🌿 Stat Box
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
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}

// 🏅 Achievement Icon
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
    return AnimatedOpacity(
      opacity: locked ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: locked
                ? Colors.grey.withValues(alpha: 0.2)
                : color.withValues(alpha: 0.45),
            child: Icon(icon,
                color: locked
                    ? Colors.grey.withValues(alpha: 0.7)
                    : AppColors.primaryGreen,
                size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                fontSize: 11.5,
                color: locked
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.8),
                height: 1.3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// 🕓 Activity Card
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.eco, color: AppColors.primaryGreen),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(date,
            style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ),
    );
  }
}

// 🌱 Submit Plant Dialog (popup)
class SubmitPlantDialog extends StatelessWidget {
  const SubmitPlantDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController scientificController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Submit a Plant',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share your plant discovery with the community',
                style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                    SizedBox(height: 6),
                    Text('Click to upload photo',
                        style: TextStyle(color: Colors.grey)),
                    Text('PNG, JPG up to 10MB',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _inputField('Plant Name', 'e.g. Monstera Deliciosa', nameController),
            _inputField('Scientific Name (Optional)',
                'e.g. Monstera deliciosa', scientificController),
            _inputField('Location in Garden', 'e.g. Tropical Zone A',
                locationController),
            _inputField('Description (Optional)',
                'Tell us about this plant...', descriptionController,
                maxLines: 3),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your submission will be reviewed by our team before being added to the garden database.',
                      style: TextStyle(
                          color: Colors.black87, fontSize: 12, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.upload, size: 18),
          label: const Text('Submit Plant'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label, String hint, TextEditingController ctrl,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
