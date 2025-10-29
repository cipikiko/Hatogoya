import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nastavenia'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTokens.tealGradient),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            NeonCard(
              color: AppTokens.cardDark,
              shadows: AppTokens.tileShadow,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Icon(Icons.notifications_outlined, color: AppTokens.emerald500),
                title: Text('Upozornenia', style: AppTokens.h1),
                subtitle: Text(
                  'Správa notifikácií bude dostupná čoskoro',
                  style: AppTokens.body,
                ),
                trailing: Icon(Icons.chevron_right, color: AppTokens.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/// kra kra kra
