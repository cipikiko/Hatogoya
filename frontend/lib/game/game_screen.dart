// lib/game/game_screen.dart
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';
import '../screens/plants_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  void _openPlants(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: AppTokens.pageBg,
          body: Stack(
            children: [
              const PlantsScreen(),

              // 🔙 just a small arrow, no square, placed high-left under status bar
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 8), // a bit lower and inset
                    child: IconButton(
                      iconSize: 26,                 // slightly bigger
                      splashRadius: 22,             // smaller ripple
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTokens.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      body: Stack(
        children: [
          // prázdne tmavé pozadie, pripravené na herné prvky

          // 📖 pravý horný roh: Neon tlačidlo s ikonou knihy (spúšťa PlantsScreen)
          Positioned(
            top: 16,
            right: 16,
            child: NeonCard(
              color: AppTokens.cardDark,
              shadows: AppTokens.tileShadow,
              radius: AppTokens.radiusMd,
              padding: const EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                onTap: () => _openPlants(context),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: AppTokens.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
