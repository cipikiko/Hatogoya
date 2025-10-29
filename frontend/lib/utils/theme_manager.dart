import 'package:flutter/material.dart';

class ThemeManager {
  // Globálny notifier pre ThemeMode
  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);

  // Prepnutie medzi light a dark režimom
  static void toggleTheme(bool isDarkMode) {
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // Získanie aktuálneho stavu
  static bool isDarkMode() {
    return themeNotifier.value == ThemeMode.dark;
  }
}
/// kra kra kra
