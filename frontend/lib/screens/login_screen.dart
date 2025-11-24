import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppTokens.textSecondary),
    filled: true,
    fillColor: AppTokens.cardDark,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      borderSide: const BorderSide(color: AppTokens.cardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      borderSide:
      const BorderSide(color: AppTokens.emerald500, width: 1.5),
    ),
  );

  /// 🔥 LOGIN FUNKCIA – napojená na backend (/login)
  void handleLogin() async {
    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vyplňte všetky polia")),
      );
      return;
    }

    final result = await ApiService.login(username, password);

    if (result["status"] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Prihlásenie úspešné")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["body"]["message"] ?? "Nesprávne meno alebo heslo",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prihlásenie'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTokens.tealGradient),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Vitajte späť', style: AppTokens.h1),
          const SizedBox(height: 6),
          const Text(
            'Prihláste sa a pokračujte v objavovaní botanickej záhrady.',
            style: AppTokens.body,
          ),
          const SizedBox(height: 20),

          // Card
          NeonCard(
            color: AppTokens.cardDark,
            shadows: AppTokens.tileShadow,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: usernameCtrl,
                  style: const TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec('Používateľské meno'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  style: const TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec('Heslo'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.emerald500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
              ),
              child: const Text(
                'Prihlásiť sa',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Prechod na registráciu
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text.rich(
                TextSpan(
                  text: 'Nemáte účet? ',
                  style: TextStyle(
                      color: AppTokens.textPrimary, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Zaregistrujte sa',
                      style: TextStyle(
                        color: AppTokens.emerald500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
