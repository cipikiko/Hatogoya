import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailCtrl = TextEditingController();
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
      borderSide: const BorderSide(color: AppTokens.emerald500, width: 1.5),
    ),
  );
  /// kra kra kra

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prihlásenie'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: AppTokens.tealGradient)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Vitajte späť', style: AppTokens.h1),
          const SizedBox(height: 6),
          const Text('Prihláste sa do svojho účtu a pokračujte v objavovaní!', style: AppTokens.body),
          const SizedBox(height: 20),

          NeonCard(
            color: AppTokens.cardDark,
            shadows: AppTokens.tileShadow,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: emailCtrl,
                  style: const TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec('E-mail'),
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

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.emerald500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
              ),
              child: const Text('Prihlásiť sa', style: TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
              },
              child: const Text('Zabudli ste heslo?', style: TextStyle(color: AppTokens.emerald500)),
            ),
          ),

          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              child: const Text.rich(
                TextSpan(
                  text: 'Nie ste prihlásený? ',
                  style: TextStyle(color: AppTokens.textPrimary),
                  children: [
                    TextSpan(
                      text: 'Zaregistrujte sa',
                      style: TextStyle(color: AppTokens.emerald500, fontWeight: FontWeight.bold),
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
