import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'lib/game/assets/lottie/Walking Pothos.json', // ← cesta k tvojmu súboru
          width: 200,
          height: 200,
          repeat: true,   // prehrávať stále
          animate: true,  // spustiť animáciu
        ),
      ),
    );
  }
}
