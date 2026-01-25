import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  Future<void> _startFlow() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final token = await AuthService.getToken();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => token == null
            ? const RegisterScreen()
            : const MainScreen(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        'lib/utils/images/loading_screen.png',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
