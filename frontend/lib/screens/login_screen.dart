import 'package:flutter/material.dart';
import 'forgot_password_screen.dart';

import '../theme/tokens.dart';
import '../widgets/neon.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import '../services/auth_service.dart';
import '../main.dart';
import '../lang/strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  // ✅ DEV OFFLINE LOGIN
  static const String _devUser = 'panic';
  static const String _devPass = 'panic';

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: AppTokens.textSecondary),
    filled: true,
    fillColor: AppTokens.cardDark,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      borderSide: BorderSide(color: AppTokens.cardBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      borderSide: const BorderSide(color: AppTokens.emerald500, width: 1.5),
    ),
  );

  // ✅ RESEND VERIFICATION EMAIL
  Future<void> resendVerificationEmail() async {
    final email = usernameCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Zadaj e-mail a skús znova.")),
      );
      return;
    }

    final result = await ApiService.resendVerification(email);
    if (!mounted) return;

    final msg = (result["body"] is Map && result["body"]["message"] != null)
        ? result["body"]["message"].toString()
        : "Overovací e-mail bol odoslaný (ak účet existuje).";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> handleLogin() async {
    final tr = context.tr;

    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.loginFillAllFields)),
      );
      return;
    }

    // ✅ OFFLINE DEV BYPASS
    if (username.toLowerCase() == _devUser && password == _devPass) {
      await AuthService.saveToken('DEV_TOKEN');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.loginDevOffline)),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
      return;
    }

    // Normálny login cez backend
    final result = await ApiService.login(username, password);
    if (!mounted) return;

    if (result["status"] == 200) {
      final body = result["body"] as Map<String, dynamic>;
      final token = body["token"]?.toString() ?? username;

      await AuthService.saveToken(token);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.loginSuccess)),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else if (result["status"] == 403) {
      // ✅ Email nie je overený + ponúkneme resend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Najprv potvrď e-mail. Ak ti nič neprišlo, pošli si overenie znova."),
          action: SnackBarAction(
            label: "Poslať znova",
            onPressed: resendVerificationEmail,
          ),
        ),
      );
    } else {
      final msg = (result["body"] is Map && result["body"]["message"] != null)
          ? result["body"]["message"].toString()
          : tr.loginInvalidCreds;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.loginTitle),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTokens.tealGradient),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(tr.loginWelcomeTitle, style: AppTokens.h1),
          const SizedBox(height: 6),
          Text(tr.loginWelcomeSubtitle, style: AppTokens.body),
          const SizedBox(height: 20),
          NeonCard(
            color: AppTokens.cardDark,
            shadows: AppTokens.tileShadow,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: usernameCtrl,
                  style: TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec(tr.loginUsernameLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  style: TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec(tr.loginPasswordLabel),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
              child: Text(
                tr.loginButton,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: Text.rich(
                TextSpan(
                  text: tr.loginNoAccount,
                  style: TextStyle(color: AppTokens.textPrimary, fontSize: 14),
                  children: [
                    TextSpan(
                      text: tr.loginGoRegister,
                      style: const TextStyle(
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
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                );
              },
              child: Text(
                tr.loginForgotPassword,
                style: TextStyle(
                  color: AppTokens.emerald500,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
