import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('O aplikácii'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '🌿 Botanik',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Verzia 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              'Botanik je moderná mobilná aplikácia určená pre objavovanie a evidenciu rastlín v botanickej záhrade. '
                  'Používateľom umožňuje skenovať rastliny, sledovať svoj pokrok, získavať odznaky a objavovať nové druhy. '
                  'Aplikácia je súčasťou projektu Digital Garden Experience realizovaného v spolupráci s TUKE.',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'Autori:\nTím Hatogoya & tím Botanickej záhrady',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
