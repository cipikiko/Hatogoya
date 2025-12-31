// lib/game/game_screen.dart
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      body: const SizedBox.expand(),
    );
  }
}
