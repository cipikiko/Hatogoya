import 'package:flutter/material.dart';

/// Svetlá botanická téma: F1F7ED (canvas), 243E36 (dark green), 7CA982 (mid green)
class AppTokens {
  /* ============ Base Palette ============ */
  static const Color canvasLight = Color(0xFFF1F7ED); // pozadie
  static const Color greenDark   = Color(0xFF243E36); // tmavozelená (text/akcent)
  static const Color greenMid    = Color(0xFF7CA982); // hlavná zelená

  /* ============ Colors ============ */
  // Pozadia
  static const Color pageBg          = canvasLight;
  static const Color headerBg        = canvasLight;
  static const Color headerSeparator = Color(0xFFD5E8DC); // jemná línia

  // Karty a okraje (svetlý povrch)
  static const Color cardSurface = Colors.white;
  static const Color cardDark    = cardSurface;
  static const Color cardBorder  = Color(0xFFC8DACF);

  // Navigácia dole (svetlá)
  static const Color navBg         = Colors.white;
  static const Color navBorder     = Color(0xFFCADFD3);
  static const Color navUnselected = Color(0xFF7B8A84);

  // Minor UI prvky
  static const Color handle  = Color(0xFFCADFD3);
  static const Color divider = Color(0xFFE3F0E9);

  // Brand – zelená paleta
  static const Color emerald500 = greenMid;          // primár
  static const Color green600   = Color(0xFF6A9474);
  static const Color green700   = greenDark;
  static const Color green400   = Color(0xFF9BC49F);

  // Texty
  static const Color textPrimary   = greenDark;
  static const Color textSecondary = Color(0xFF4E6B60);

  // Akcenty
  static const Color xpYellow  = Color(0xFFFACC15);
  static const Color xpYellow2 = Color(0xFFFBBF24);
  static const Color orange    = Color(0xFFFF7A1F);
  static const Color purple    = Color(0xFF8B5CF6);

  /* ============ Gradients ============ */
  // Kompat názov (niekde ho voláš) – už s novými farbami
  static const LinearGradient tealGradient = LinearGradient(
    colors: [greenMid, green400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Preferovaný názov
  static const LinearGradient headerGradient = LinearGradient(
    colors: [greenMid, green400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Panel (bottom sheet) jemný svetlý
  static LinearGradient panelGradient() => const LinearGradient(
    colors: [Colors.white, Color(0xFFF4FBF7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Progress bar – od tmavšej k svetlej
  static const LinearGradient progressGradient = LinearGradient(
    colors: [green600, green400],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Stat tile akcenty (ponechané)
  static LinearGradient statOrange() => const LinearGradient(
    colors: [Color(0xFFFFA94D), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient statGreen() => const LinearGradient(
    colors: [green400, green600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient statPurple() => const LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /* ============ Shadows ============ */
  static List<BoxShadow> glow(Color seed, {double blur = 10, double y = 4, double alpha = .12}) => [
    BoxShadow(color: seed.withValues(alpha: alpha), blurRadius: blur, offset: Offset(0, y)),
  ];
  static const List<BoxShadow> tileShadow = [
    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 5)),
  ];

  /* ============ Radii ============ */
  static const double radiusLg = 20;
  static const double radiusMd = 16;
  static const double radiusSm = 12;

  /* ============ Typography ============ */
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
    fontSize: 18,
  );

  /* ============ Durations ============ */
  static const Duration dPulse  = Duration(milliseconds: 1600);
  static const Duration dBounce = Duration(milliseconds: 2000);
}
