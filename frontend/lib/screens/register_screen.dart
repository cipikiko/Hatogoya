import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../widgets/neon.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../lang/strings.dart';

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

  bool _hasUpper = false;
  bool _hasLower = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;
  bool _noSpaces = true;
  bool _lenOk = false;
  bool _matchOk = false;

  String _inlineMsg = "Start typing a password to see requirements.";
  bool _canSubmit = false;

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

  bool _reHasUpper(String v) => RegExp(r'[A-Z]').hasMatch(v);
  bool _reHasLower(String v) => RegExp(r'[a-z]').hasMatch(v);
  bool _reHasNumber(String v) => RegExp(r'[0-9]').hasMatch(v);
  bool _reHasSpecial(String v) => RegExp(r'[^A-Za-z0-9]').hasMatch(v);
  bool _reNoSpaces(String v) => !RegExp(r'\s').hasMatch(v);

  void _updatePasswordUI() {
    final v = passCtrl.text;
    final v2 = confirmCtrl.text;

    final lenOk = v.length >= 8;
    final hasUpper = _reHasUpper(v);
    final hasLower = _reHasLower(v);
    final hasNumber = _reHasNumber(v);
    final hasSpecial = _reHasSpecial(v);
    final noSpaces = _reNoSpaces(v);

    // match only matters after confirm has something
    final matchOk = v2.isNotEmpty && v == v2;

    final missing = <String>[];
    if (!lenOk) missing.add("at least 8 characters");
    if (!hasUpper) missing.add("uppercase letter");
    if (!hasLower) missing.add("lowercase letter");
    if (!hasNumber) missing.add("number");
    if (!hasSpecial) missing.add("special character");
    if (!noSpaces) missing.add("no spaces");
    if (v2.isNotEmpty && v != v2) missing.add("passwords must match");

    final canSubmit = lenOk &&
        hasUpper &&
        hasLower &&
        hasNumber &&
        hasSpecial &&
        noSpaces &&
        matchOk;

    String msg;
    if (v.isEmpty) {
      msg = "Start typing a password to see requirements.";
    } else if (canSubmit) {
      msg = "✅ Ready to submit";
    } else if (missing.isEmpty && v2.isEmpty) {
      msg = "Keep typing to confirm your password.";
    } else {
      msg = "Missing: ${missing.join(", ")}.";
    }

    setState(() {
      _lenOk = lenOk;
      _hasUpper = hasUpper;
      _hasLower = hasLower;
      _hasNumber = hasNumber;
      _hasSpecial = hasSpecial;
      _noSpaces = noSpaces;
      _matchOk = matchOk;

      _inlineMsg = msg;
      _canSubmit = canSubmit;
    });
  }

  /// Register
  Future<void> handleRegister() async {
    final tr = context.tr;

    final username = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final password = passCtrl.text;
    final confirm = confirmCtrl.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.registerFillAllFields)),
      );
      return;
    }

    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password does not meet requirements.")),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.registerPasswordsMismatch)),
      );
      return;
    }

    final result = await ApiService.register(username, email, password);
    if (!mounted) return;

    if (result["status"] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr.registerSuccess)),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      final msg = (result["body"] is Map && result["body"]["message"] != null)
          ? result["body"]["message"].toString()
          : tr.registerError;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    passCtrl.addListener(_updatePasswordUI);
    confirmCtrl.addListener(_updatePasswordUI);
    _updatePasswordUI();
  }

  @override
  void dispose() {
    passCtrl.removeListener(_updatePasswordUI);
    confirmCtrl.removeListener(_updatePasswordUI);

    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Widget _ruleRow(bool ok, String text) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.cardBorder),
        color: AppTokens.cardDark,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ok ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppTokens.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    final inlineColor = _canSubmit
        ? const Color(0xFFBBF7D0)
        : const Color(0xFFFECACA);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.registerTitle),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTokens.tealGradient),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(tr.registerHeaderTitle, style: AppTokens.h1),
          const SizedBox(height: 6),
          Text(tr.registerHeaderSubtitle, style: AppTokens.body),
          const SizedBox(height: 20),

          NeonCard(
            color: AppTokens.cardDark,
            shadows: AppTokens.tileShadow,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec(tr.registerNameLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  style: TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec(tr.registerEmailLabel),
                ),
                const SizedBox(height: 12),

                // ✅ Password + Confirm directly under each other
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  style: TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec(tr.registerPasswordLabel),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  style: TextStyle(color: AppTokens.textPrimary),
                  decoration: _dec(tr.registerConfirmPasswordLabel),
                ),

                const SizedBox(height: 8),

                // ✅ Inline message (English)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _inlineMsg,
                    style: TextStyle(
                      color: passCtrl.text.isEmpty ? AppTokens.textSecondary : inlineColor,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ Rules checklist (English)
                _ruleRow(_lenOk, "At least 8 characters"),
                _ruleRow(_hasUpper, "One uppercase letter (A–Z)"),
                _ruleRow(_hasLower, "One lowercase letter (a–z)"),
                _ruleRow(_hasNumber, "One number (0–9)"),
                _ruleRow(_hasSpecial, "One special character (e.g. !@#\$)"),
                _ruleRow(_noSpaces, "No spaces"),
                _ruleRow(_matchOk, "Passwords match"),

                const SizedBox(height: 12),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canSubmit ? handleRegister : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.emerald500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
              ),
              child: Text(
                tr.registerButton,
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
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text.rich(
                TextSpan(
                  text: tr.registerAlreadyHave,
                  style: TextStyle(
                    color: AppTokens.textPrimary,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: tr.registerGoLogin,
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
        ],
      ),
    );
  }
}
