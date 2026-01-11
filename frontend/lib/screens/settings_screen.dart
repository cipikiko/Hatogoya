import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/neon.dart';
import 'terms_screen.dart';

import '../services/lang_service.dart';
import '../lang/strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = false;
  bool vibrations = true;
  bool sounds = true;

  bool darkMode = false;

  bool _loading = true;
  bool _themeLock = false;

  String _langCode = 'en';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      notifications = prefs.getBool('notifications') ?? false;
      vibrations = prefs.getBool('vibrations') ?? true;
      sounds = prefs.getBool('sounds') ?? true;

      darkMode = prefs.getBool('darkMode') ?? AppTheme.isDark;

      _langCode = prefs.getString('lang_code') ?? LangService.code;

      _loading = false;
    });

    if (notifications) {
      final st = await Permission.notification.status;
      if (!st.isGranted && mounted) {
        setState(() => notifications = false);
        await _saveBool('notifications', false);
      }
    }
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _handleNotificationsToggle(bool v) async {
    // ✅ capture before any await (no "context across async gaps")
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (v) {
      final status = await Permission.notification.status;

      if (!status.isGranted) {
        final res = await Permission.notification.request();

        if (!res.isGranted) {
          if (!mounted) return;

          setState(() => notifications = false);
          await _saveBool('notifications', false);

          if (!mounted) return;

          if (res.isPermanentlyDenied) {
            messenger?.showSnackBar(
              SnackBar(
                content: const Text(
                  'Notifications are blocked. Enable them in your phone settings.',
                ),
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: openAppSettings,
                ),
              ),
            );
          } else {
            messenger?.showSnackBar(
              const SnackBar(content: Text('Notifications were not allowed.')),
            );
          }
          return;
        }
      }

      if (!mounted) return;
      setState(() => notifications = true);
      await _saveBool('notifications', true);

      if (!mounted) return;
      messenger?.showSnackBar(
        const SnackBar(content: Text('Notifications enabled.')),
      );
    } else {
      if (!mounted) return;
      setState(() => notifications = false);
      await _saveBool('notifications', false);
    }
  }


  Widget _switchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    final onSurface = cs.onSurface;
    final subtitleColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.75) ??
            onSurface.withValues(alpha: 0.75);

    return NeonCard(
      color: AppTokens.cardDark,
      shadows: AppTokens.tileShadow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(icon, color: AppTokens.emerald500),
        title: Text(
          title,
          style: TextStyle(
            color: onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: subtitleColor, fontSize: 13.5),
        ),
        value: value,
        onChanged: _themeLock ? null : onChanged,
      ),
    );
  }

  String _langLabel(String code) {
    switch (code) {
      case 'sk':
        return '${context.tr.slovak} (SK)';
      case 'nl':
        return '${context.tr.dutch} (NL)';
      case 'en':
      default:
        return '${context.tr.english} (EN)';
    }
  }


  String _langFlag(String code) {
    switch (code) {
      case 'sk':
        return '🇸🇰';
      case 'nl':
        return '🇳🇱';
      case 'en':
      default:
        return '🇬🇧'; // English
    }
  }

  Future<void> _showLanguageDialog() async {
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(context.tr.languageSelectTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LangChoiceTile(
                flag: _langFlag('sk'),
                label: _langLabel('sk'),
                selected: _langCode == 'sk',
                onTap: () => Navigator.pop(ctx, 'sk'),
              ),
              const SizedBox(height: 6),
              _LangChoiceTile(
                flag: _langFlag('en'),
                label: _langLabel('en'),
                selected: _langCode == 'en',
                onTap: () => Navigator.pop(ctx, 'en'),
              ),
              const SizedBox(height: 6),
              _LangChoiceTile(
                flag: _langFlag('nl'),
                label: _langLabel('nl'),
                selected: _langCode == 'nl',
                onTap: () => Navigator.pop(ctx, 'nl'),
              ),
            ],
          ),
        );
      },
    );

    if (picked == null) return;

    setState(() => _langCode = picked);
    await LangService.setCode(picked);
  }

  Widget _languageTile(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final onSurface = cs.onSurface;
    final subtitleColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.75) ??
            onSurface.withValues(alpha: 0.75);

    return NeonCard(
      color: AppTokens.cardDark,
      shadows: AppTokens.tileShadow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        onTap: _showLanguageDialog,
        child: Padding(
          // rovnaký “feel” ako SwitchListTile
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // Icon - zarovnanie ako SwitchListTile secondary
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 12),
                child: Icon(Icons.language, color: AppTokens.emerald500),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr.language,
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr.languageSubtitle, // -> "Výber jazykov"
                      style: TextStyle(color: subtitleColor, fontSize: 13.5),
                    ),
                  ],
                ),
              ),

              // napravo ukáž vybraný jazyk (vlajka + skratka), potom chevron
              Text(
                _langCode.toUpperCase(),
                style: TextStyle(color: subtitleColor, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right, color: subtitleColor),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerGradient =
    isDark ? AppTokens.tealGradientDark : AppTokens.tealGradientLight;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final onSurface = cs.onSurface;
    final subtitleColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.75) ??
            onSurface.withValues(alpha: 0.75);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.settingsTitle),
        foregroundColor: Colors.white,
        flexibleSpace: Container(decoration: BoxDecoration(gradient: headerGradient)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 🌙 Dark mode
          _switchTile(
            context: context,
            icon: Icons.dark_mode_outlined,
            title: context.tr.darkMode,
            subtitle: darkMode ? context.tr.darkModeOn : context.tr.darkModeOff,
            value: darkMode,
            onChanged: (v) async {
              if (_themeLock) return;

              setState(() {
                _themeLock = true;
                darkMode = v;
              });

              AppTheme.setDarkFast(v);
              await AppTheme.persistDarkDebounced(v);

              if (!mounted) return;
              setState(() => _themeLock = false);
            },
          ),

          // 🔔 Notifications
          _switchTile(
            context: context,
            icon: Icons.notifications_outlined,
            title: context.tr.notifications,
            subtitle: notifications ? context.tr.notificationsOn : context.tr.notificationsOff,

            value: notifications,
            onChanged: (v) async {
              setState(() => notifications = v);
              await _handleNotificationsToggle(v);
            },
          ),

          // 📳 Vibrations
          _switchTile(
            context: context,
            icon: Icons.vibration,
            title: context.tr.vibrations,
            subtitle: vibrations ? context.tr.vibrationsOn : context.tr.vibrationsOff,

            value: vibrations,
            onChanged: (v) async {
              setState(() => vibrations = v);
              await _saveBool('vibrations', v);
            },
          ),

          // 🌍 Language (AFTER vibrations)
          _languageTile(context),

          const SizedBox(height: 24),

          // 📄 Privacy & Terms
          NeonCard(
            color: AppTokens.cardDark,
            shadows: AppTokens.tileShadow,
            padding: const EdgeInsets.all(14),
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: AppTokens.emerald500),
              title: Text(context.tr.privacyTerms,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(context.tr.privacyTermsSubtitle,
                style: TextStyle(color: subtitleColor, fontSize: 13.5),
              ),
              trailing: Icon(Icons.chevron_right, color: subtitleColor),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LangChoiceTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChoiceTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final onSurface = cs.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTokens.cardBorder),
          color: selected
              ? AppTokens.emerald500.withValues(alpha: 0.10)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: AppTokens.emerald500),
          ],
        ),
      ),
    );
  }
}
