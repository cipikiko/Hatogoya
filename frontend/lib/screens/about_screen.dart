import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';
import '../lang/strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.aboutTitle),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTokens.tealGradient),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          NeonCard(
            color: AppTokens.cardDark,
            shadows: AppTokens.tileShadow,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr.aboutAppName, style: AppTokens.h1),
                const SizedBox(height: 6),
                Text(tr.aboutVersion, style: AppTokens.body),
                const SizedBox(height: 16),
                Text(tr.aboutDescription, style: AppTokens.body),
                const SizedBox(height: 16),
                Text(tr.aboutAuthors, style: AppTokens.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
