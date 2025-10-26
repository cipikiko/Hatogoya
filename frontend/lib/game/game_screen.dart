import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showUI = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showUI = true;
      });
    });
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opustiť hru?'),
        content: const Text('Naozaj chcete odísť z hry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Zostať'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Odísť'),
          ),
        ],
      ),
    );

    if (shouldExit ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🌱 Lottie animácia na pozadí
          Positioned.fill(
            child: Lottie.asset(
              'lib/game/assets/lottie/Walking Pothos.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),

          // 🌸 Po načítaní sa zobrazí UI (tlačidlo na exit)
          if (_showUI)
            Positioned(
              top: 40,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: _confirmExit,
              ),
            ),

          // 🪴 Textový overlay
          if (_showUI)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    '🌿 Botanická hra 🌿',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Získavaj XP a pomáhaj rastline rásť!',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
