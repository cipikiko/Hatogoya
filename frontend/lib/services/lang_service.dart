import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LangService {
  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  static const _key = 'lang_code';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    locale.value = Locale(code);
  }

  static Future<void> setCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
    locale.value = Locale(code);
  }

  static String get code => locale.value.languageCode;
}
