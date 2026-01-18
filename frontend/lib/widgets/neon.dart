import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Jemná pulzujúca žiara okolo childa
class PulseGlow extends StatelessWidget {
  final Widget child;
  final Color color;
  final double blur;
  const PulseGlow({super.key, required this.child, required this.color, this.blur = 14});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(color: color.withValues(alpha: .22), blurRadius: blur, spreadRadius: 0.5),
      ]),
      child: child,
    );
  }
}

/// Jemný vertikálny bounce
class BounceGentle extends StatelessWidget {
  final Widget child;
  const BounceGentle({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 2 * math.pi),
      duration: AppTokens.dBounce,
      curve: Curves.easeInOut,
      builder: (_, t, __) => Transform.translate(
        offset: Offset(0, -math.sin(t) * 1.6),
        child: child,
      ),
    );
  }
}

/// Žltá iskra
class Sparkle extends StatelessWidget {
  final double size;
  const Sparkle({super.key, this.size = 18});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .92, end: 1.08),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (_, s, __) =>
          Transform.scale(scale: s, child: Icon(Icons.auto_awesome, size: size, color: AppTokens.xpYellow)),
    );
  }
}

/// Karta s jemným gradientom a borderline
class NeonCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final List<BoxShadow>? shadows;

  const NeonCard({
    super.key,
    required this.child,
    this.gradient,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = AppTokens.radiusLg,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppTokens.cardSurface,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppTokens.cardBorder),
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}

/// Okrúhly gradient chip
class NeonChipText extends StatelessWidget {
  final String text;
  const NeonChipText(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTokens.xpYellow, AppTokens.xpYellow2]),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
class NeonChip extends StatelessWidget {
  final String text;
  const NeonChip(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTokens.xpYellow, AppTokens.xpYellow2]),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
/// Progress bar zelený
class GradientProgressBar extends StatelessWidget {
  final double value; // 0..1
  final double height;
  const GradientProgressBar({super.key, required this.value, this.height = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTokens.green600, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTokens.progressGradient,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}
