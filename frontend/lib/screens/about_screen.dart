import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('O aplikácii'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTokens.tealGradient)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          NeonCard(
            color: AppTokens.cardDark,
            shadows: AppTokens.tileShadow,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Botanik', style: AppTokens.h1),
                SizedBox(height: 6),
                Text('Verzia 1.0.0', style: AppTokens.body),
                SizedBox(height: 16),
                Text(
                  'Botanik je moderná mobilná aplikácia určená pre objavovanie a evidenciu rastlín v botanickej záhrade. '
                      'Umožňuje skenovať rastliny, sledovať pokrok, získavať odznaky a objavovať nové druhy. '
                      'Aplikácia je súčasťou projektu Digital Garden Experience realizovaného v spolupráci s TUKE.',
                  style: AppTokens.body,
                ),
                SizedBox(height: 16),
                Text(
                  'Autori:\nTím Hatogoya & tím Botanickej záhrady',
                  style: AppTokens.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
