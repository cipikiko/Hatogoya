import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerGradient =
    isDark ? AppTokens.tealGradientDark : AppTokens.tealGradientLight;

    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).textTheme.bodyMedium?.color ??
        onSurface.withValues(alpha: 0.75);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Terms'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: headerGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: DefaultTextStyle(
          style: TextStyle(color: onSurface),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your privacy is important to us. This application does not '
                    'share personal data with third parties. Collected information '
                    'is used only to improve the user experience.',
                style: TextStyle(color: secondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Text(
                'Terms of Use',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'By using this application, you agree to use it responsibly. '
                    'All content is provided as-is without warranties. '
                    'Misuse of the application is prohibited.',
                style: TextStyle(color: secondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Text(
                'Contact',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If you have any questions regarding privacy or terms, '
                    'please contact the application administrator.',
                style: TextStyle(color: secondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
