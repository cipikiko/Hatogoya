import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';
import '../lang/strings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {


  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    // demo numbers (your real values can come later)
    const foundPlants = 47;
    const totalPlants = 120;

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
                  Text(
                    tr.profilePlantsDiscovered,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    child: LinearProgressIndicator(
                      value: foundPlants / totalPlants,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      tr.profileProgressPlants(foundPlants, totalPlants),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Stats (2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatBox(label: tr.profileTotalVisits, value: '32', icon: Icons.place),
              _StatBox(label: tr.profilePlantsFound, value: '$foundPlants', icon: Icons.eco),
            ],
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

          _ActivityCard(
            title: tr.profileActivity1,
            date: 'Oct 15, 2025',
            color: const Color(0xFFA5D6A7),
          ),
          _ActivityCard(
            title: tr.profileActivity2,
            date: 'Oct 14, 2025',
            color: const Color(0xFFB39DDB),
          ),
          _ActivityCard(
            title: tr.profileActivity3,
            date: 'Oct 13, 2025',
            color: const Color(0xFF81C784),
          ),

          const SizedBox(height: 10),


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

/* ===== Submit Plant Dialog ===== */

class SubmitPlantDialog extends StatelessWidget {
  const SubmitPlantDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

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
                  Text(
                    tr.submitTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(tr.submitSubtitle, style: AppTokens.body),
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
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined, size: 40, color: AppTokens.textSecondary),
                          const SizedBox(height: 6),
                          Text(tr.submitUploadTitle, style: AppTokens.body),
                          Text(
                            tr.submitUploadHint,
                            style: TextStyle(color: AppTokens.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _inputField(tr.submitFieldPlantName, tr.submitHintPlantName, nameController),
                  _inputField(tr.submitFieldScientificName, tr.submitHintScientificName, scientificController),
                  _inputField(tr.submitFieldLocation, tr.submitHintLocation, locationController),
                  _inputField(tr.submitFieldDescription, tr.submitHintDescription, descriptionController, maxLines: 3),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTokens.cardDark,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      border: Border.all(color: AppTokens.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTokens.emerald500),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(tr.submitInfoReview, style: AppTokens.body),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(tr.cancel),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.upload, size: 18),
                        label: Text(tr.submitButton),
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

  Widget _inputField(
      String label,
      String hint,
      TextEditingController ctrl, {
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(color: AppTokens.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: AppTokens.textSecondary),
          labelStyle: TextStyle(color: AppTokens.textSecondary),
          filled: true,
          fillColor: AppTokens.cardDark,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            borderSide: BorderSide(color: AppTokens.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            borderSide: BorderSide(color: AppTokens.emerald500),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }
}
