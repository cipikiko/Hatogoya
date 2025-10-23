import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/theme_manager.dart'; // ✅ import

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDark = ThemeManager.isDarkMode();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nastavenia'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text('Tmavý režim'),
            subtitle: const Text('Prepni medzi svetlým a tmavým motívom'),
            activeColor: AppColors.primaryGreen,
            value: isDark,
            onChanged: (value) {
              ThemeManager.toggleTheme(value);
              setState(() {});
            },
          ),
          const Divider(height: 30),
          const ListTile(
            leading: Icon(Icons.notifications_outlined, color: AppColors.primaryGreen),
            title: Text('Upozornenia'),
            subtitle: Text('Správa notifikácií bude dostupná čoskoro'),
          ),
        ],
      ),
    );
  }
}
