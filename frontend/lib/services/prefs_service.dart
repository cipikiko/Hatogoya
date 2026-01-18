import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static Future<bool> vibrationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vibrations') ?? true;
  }

  static Future<bool> notificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications') ?? false;
  }
}
