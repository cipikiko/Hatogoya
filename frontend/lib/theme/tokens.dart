import 'package:flutter/material.dart';

/// Centrálne design tokens pre celú appku (tmavý teal/emerald neon).
class AppTokens {
  /* ================= Colors ================= */

  // Základné pozadia
  static const Color pageBg          = Color(0xFF0B0F0C); // celostránkové pozadie
  static const Color headerBg        = Color(0xFF0E1613); // pozadie top pásu
  static const Color headerSeparator = Color(0xFF1F2A25); // deliaca línia pod headerom

  // Karty / okraje
  static const Color cardDark   = Color(0xFF151A15);
  static const Color cardBorder = Color(0xFF1E3A2A);

  // Navigácia dole
  static const Color navBg         = Color(0xFF121814);
  static const Color navBorder     = Color(0xFF1E3A2A);
  static const Color navUnselected = Color(0xFF6B7280);

  // Minor UI prvky v sheet-e
  static const Color handle  = Color(0xFF3B4A42); // drag handle
  static const Color divider = Color(0xFF2A3A33);

  // Brand – teal/emerald
  static const Color teal600     = Color(0xFF0D9488);
  static const Color teal400     = Color(0xFF14B8A6);
  static const Color emerald500  = Color(0xFF10B981);
  static const Color cyan400     = Color(0xFF06B6D4);

  // Texty
  static const Color textPrimary   = Color(0xFFE8F5E9);
  static const Color textSecondary = Color(0xFFA7F3D0);

  // Akcenty (XP, ikony)
  static const Color xpYellow  = Color(0xFFFACC15);
  static const Color xpYellow2 = Color(0xFFFBBF24);
  static const Color orange    = Color(0xFFFF6B1A);
  static const Color purple    = Color(0xFF8B5CF6);

  /* ================= Gradients ================= */

  // Hlavný tyrkysový gradient (header, CTA, Explore)
  static const LinearGradient tealGradient = LinearGradient(
    colors: [teal600, teal400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Panel (bottom-sheet) – veľmi tmavý teal/emerald
  static LinearGradient panelGradient() => const LinearGradient(
    colors: [Color(0xFF0E1613), Color(0xFF0B1411)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Progress bar (emerald → cyan)
  static const LinearGradient progressGradient = LinearGradient(
    colors: [emerald500, cyan400],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Stat tile akcenty
  static LinearGradient statOrange() => const LinearGradient(
    colors: [Color(0xFFFF8A3A), Color(0xFFFF4B2B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient statGreen() => const LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient statPurple() => const LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /* ================= Shadows ================= */

  // Univerzálne žiarenie (neon glow)
  static List<BoxShadow> glow(Color seed, {double blur = 18, double y = 6, double alpha = .28}) => [
    BoxShadow(
      color: seed.withValues(alpha: alpha), // vyhýba sa deprecated withOpacity
      blurRadius: blur,
      offset: Offset(0, y),
    ),
  ];

  // Jemný tieň pod kachličkou / blobom
  static const List<BoxShadow> tileShadow = [
    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 6)),
  ];

  /* ================= Radii ================= */

  static const double radiusLg = 22;
  static const double radiusMd = 18;
  static const double radiusSm = 12;

  /* ================= Typography ================= */

  static const TextStyle h1 = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    color: textSecondary,
    fontSize: 14,
  );

  static const TextStyle titleWhite = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  /* ================= Durations ================= */

  static const Duration dPulse  = Duration(milliseconds: 1600);
  static const Duration dBounce = Duration(milliseconds: 2000);
}
