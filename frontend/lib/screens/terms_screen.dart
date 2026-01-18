import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../lang/strings.dart';

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
        title: Text(context.tr.termsTitle),
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
                context.tr.privacyPolicyTitle,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr.privacyPolicyBody,
                style: TextStyle(color: secondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              Text(
                context.tr.termsOfUseTitle,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr.termsOfUseBody,
                style: TextStyle(color: secondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              Text(
                context.tr.contactTitle,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr.contactBody,
                style: TextStyle(color: secondary, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
