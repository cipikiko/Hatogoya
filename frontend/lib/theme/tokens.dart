import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Botanická téma – TOKENS (napojené na AppTheme.isDark)
class AppTokens {
  AppTokens._();

  static bool get _dark => AppTheme.isDark;

  /* ============ Base Palette ============ */
  // LIGHT
  static const Color canvasLight = Color(0xFFF1F7ED); // pozadie
  static const Color greenDark = Color(0xFF243E36); // tmavozelená (text/akcent)
  static const Color greenMid = Color(0xFF7CA982); // hlavná zelená

  // DARK
  static const Color canvasDark = Color(0xFF0B1220);
  static const Color surfaceDark = Color(0xFF0F1A2B);
  static const Color borderDark = Color(0xFF233247);

  static const Color textPrimaryDark = Color(0xFFEAF2EC);
  static const Color textSecondaryDark = Color(0xFFB7C8BE);

  static const Color navUnselectedDark = Color(0xFF9FB3A8);
  static const Color dividerDark = Color(0xFF1E2B3F);
  static const Color handleDark = Color(0xFF2B3C55);

  /* ============ Brand – nemeníme ============ */
  static const Color emerald500 = greenMid;
  static const Color green600 = Color(0xFF6A9474);
  static const Color green700 = greenDark;
  static const Color green400 = Color(0xFF9BC49F);

  /* ============ Light Surface ============ */
  static const Color cardLight = Colors.white;
  static const Color borderLight = Color(0xFFC8DACF);

  static const Color navBgLight = Colors.white;
  static const Color navBorderLight = Color(0xFFCADFD3);
  static const Color navUnselectedLight = Color(0xFF7B8A84);

  static const Color dividerLight = Color(0xFFE3F0E9);
  static const Color handleLight = Color(0xFFCADFD3);

  static const Color headerSeparatorLight = Color(0xFFD5E8DC);

  static const Color textPrimaryLight = greenDark;
  static const Color textSecondaryLight = Color(0xFF4E6B60);

  /* ============ Getters (kompatibilita pre celý projekt) ============ */
  // Pozadia
  static Color get pageBg => _dark ? canvasDark : canvasLight;
  static Color get headerBg => _dark ? canvasDark : canvasLight;
  static Color get headerSeparator => _dark ? dividerDark : headerSeparatorLight;

  // Karty a okraje
  static Color get cardSurface => _dark ? surfaceDark : cardLight;
  static Color get cardDark => cardSurface; // starý názov, nech fungujú screeny
  static Color get cardBorder => _dark ? borderDark : borderLight;

  // Navigácia dole
  static Color get navBg => _dark ? surfaceDark : navBgLight;
  static Color get navBorder => _dark ? borderDark : navBorderLight;
  static Color get navUnselected => _dark ? navUnselectedDark : navUnselectedLight;

  // Minor UI prvky
  static Color get divider => _dark ? dividerDark : dividerLight;
  static Color get handle => _dark ? handleDark : handleLight;

  // Texty
  static Color get textPrimary => _dark ? textPrimaryDark : textPrimaryLight;
  static Color get textSecondary => _dark ? textSecondaryDark : textSecondaryLight;

  /* ============ Akcenty ============ */
  static const Color xpYellow = Color(0xFFFACC15);
  static const Color xpYellow2 = Color(0xFFFBBF24);
  static const Color orange = Color(0xFFFF7A1F);
  static const Color purple = Color(0xFF8B5CF6);

  /* ============ Gradients ============ */
  static const LinearGradient tealGradientLight = LinearGradient(
    colors: [greenMid, green400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradientDark = LinearGradient(
    colors: [surfaceDark, canvasDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Starý názov používaný v screenoch (napr. AppBar flexibleSpace)
  static LinearGradient get tealGradient => _dark ? tealGradientDark : tealGradientLight;

  static LinearGradient get headerGradient => tealGradient;

  static const LinearGradient panelGradientLight = LinearGradient(
    colors: [Colors.white, Color(0xFFF4FBF7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient panelGradientDark = LinearGradient(
    colors: [surfaceDark, canvasDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Starý API tvar panelGradient()
  static LinearGradient panelGradient() => _dark ? panelGradientDark : panelGradientLight;

  static const LinearGradient progressGradient = LinearGradient(
    colors: [green600, green400],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

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
  static List<BoxShadow> glow(
      Color seed, {
        double blur = 10,
        double y = 4,
        double alpha = .12,
      }) =>
      [
        BoxShadow(
          color: seed.withValues(alpha: alpha),
          blurRadius: blur,
          offset: Offset(0, y),
        ),
      ];

  static const List<BoxShadow> tileShadowLight = [
    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 5)),
  ];

  static const List<BoxShadow> tileShadowDark = [
    BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 6)),
  ];

  /// Starý názov používaný v NeonCardoch
  static List<BoxShadow> get tileShadow => _dark ? tileShadowDark : tileShadowLight;

  /* ============ Radii ============ */
  static const double radiusLg = 20;
  static const double radiusMd = 16;
  static const double radiusSm = 12;

  /* ============ Typography (kompatibilita) ============ */
  /// Toto nech je getter, aby menil farbu podľa režimu.
  static TextStyle get h1 => TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get body => TextStyle(
    color: textSecondary,
    fontSize: 14,
  );

  static const TextStyle titleWhite = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );

  /* ============ Durations ============ */
  static const Duration dPulse = Duration(milliseconds: 1600);
  static const Duration dBounce = Duration(milliseconds: 2000);
}
