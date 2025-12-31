import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tokens.dart';

class AppTheme {
  AppTheme._();

  static const _darkKey = 'darkMode';

  /// MaterialApp počúva toto
  static final ValueNotifier<ThemeMode> mode =
  ValueNotifier(ThemeMode.light);

  static bool get isDark => mode.value == ThemeMode.dark;

  // debounce persist
  static bool _saving = false;
  static int _saveTicket = 0;

  /// load pri štarte
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_darkKey) ?? false;
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// UI prepnutie (okamžite)
  static void setDarkFast(bool value) {
    mode.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  /// uloženie (debounce)
  static Future<void> persistDarkDebounced(bool value) async {
    final int myTicket = ++_saveTicket;

    await Future.delayed(const Duration(milliseconds: 250));
    if (myTicket != _saveTicket) return;

    if (_saving) return;
    _saving = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkKey, value);
    } finally {
      _saving = false;
    }
  }

  // =========================
  // 🌞 LIGHT THEME
  // =========================
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,

    scaffoldBackgroundColor: AppTokens.canvasLight,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppTokens.canvasLight,
      foregroundColor: AppTokens.textPrimaryLight,
      elevation: 0,
    ),

    colorScheme: const ColorScheme.light(
      primary: AppTokens.emerald500,
      secondary: AppTokens.green600,
      surface: AppTokens.cardLight,
      onSurface: AppTokens.textPrimaryLight,
    ),

    dividerColor: AppTokens.dividerLight,

    switchTheme: SwitchThemeData(
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return AppTokens.green400;
        return AppTokens.borderLight;
      }),
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return Colors.black;
        return Colors.white;
      }),
    ),

    useMaterial3: true,
  );

  // =========================
  // 🌙 DARK THEME
  // =========================
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppTokens.canvasDark,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppTokens.canvasDark,
      foregroundColor: AppTokens.textPrimaryDark,
      elevation: 0,
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppTokens.emerald500,
      secondary: AppTokens.green600,
      surface: AppTokens.surfaceDark,
      onSurface: AppTokens.textPrimaryDark,
    ),

    dividerColor: AppTokens.dividerDark,

    switchTheme: SwitchThemeData(
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return AppTokens.green400;
        return AppTokens.borderDark;
      }),
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) return Colors.black;
        return Colors.white;
      }),
    ),

    useMaterial3: true,
  );
}
