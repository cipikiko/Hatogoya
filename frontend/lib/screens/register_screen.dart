import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController confirmCtrl = TextEditingController();

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

  /// 🔥 Funkcia na odoslanie registrácie do backendu
  void handleRegister() async {
    final username = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();

    // Kontrola prázdnych polí
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vyplňte všetky polia.")),
      );
      return;
    }

    // Kontrola hesiel
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Heslá sa nezhodujú.")),
      );
      return;
    }

    // Odoslanie na backend
    final result = await ApiService.register(username, email, password);

    if (result["status"] == 201) {
      // Úspech
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrácia bola úspešná!")),
      );

      // Prechod na login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // Chyba backendu
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["body"]["message"] ?? "Chyba pri registrácii.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrácia'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTokens.tealGradient),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Vytvorte si účet', style: AppTokens.h1),
          const SizedBox(height: 6),
          const Text(
            'Zaregistrujte sa a začnite svoju botanickú cestu.',
            style: AppTokens.body,
          ),
          const SizedBox(height: 20),

          // Form Card
          NeonCard(
            color: AppTokens.cardDark,
            shadows: AppTokens.tileShadow,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec('Meno'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec('E-mail'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  style: const TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec('Heslo'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  style: const TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec('Potvrdiť heslo'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Registračné tlačidlo
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.emerald500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
              ),
              child: const Text(
                'Zaregistrovať sa',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Prechod na login
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text.rich(
                TextSpan(
                  text: 'Už ste zaregistrovaný? ',
                  style: TextStyle(
                      color: AppTokens.textPrimary, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Prihláste sa',
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
