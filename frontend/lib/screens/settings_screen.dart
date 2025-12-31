import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import '../theme/tokens.dart';
import '../theme/app_theme.dart';
import '../widgets/neon.dart';
import 'terms_screen.dart';

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

      // dark mode (fallback na aktuálny stav)
      darkMode = prefs.getBool('darkMode') ?? AppTheme.isDark;

      _loading = false;
    });

    // Voliteľné: ak má user v appke notifications=true,
    // ale systém ich nemá povolené, zosynchronizuj to.
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
    if (v) {
      // Zapína -> skús vypýtať permission
      final status = await Permission.notification.status;

      if (!status.isGranted) {
        final res = await Permission.notification.request();

        if (!res.isGranted) {
          if (!mounted) return;

          // vráť switch späť + ulož false
          setState(() => notifications = false);
          await _saveBool('notifications', false);

          // ak je permanentlyDenied, user musí do settings
          if (res.isPermanentlyDenied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Upozornenia sú zablokované. Zapni ich v nastaveniach telefónu.',
                ),
                action: SnackBarAction(
                  label: 'Nastavenia',
                  onPressed: () => openAppSettings(),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Upozornenia neboli povolené.'),
              ),
            );
          }

          return;
        }
      }

      // Permission OK
      if (!mounted) return;
      setState(() => notifications = true);
      await _saveBool('notifications', true);

      // (Voliteľné) info
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upozornenia zapnuté.')),
      );
    } else {
      // Vypínaš len v appke (systémové povolenie nemeníme)
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
      // odporúčam cardSurface (ale nechávam tvoj cardDark kvôli kompatibilite)
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
        title: const Text('Nastavenia'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: headerGradient),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          /// 🌙 Dark mode
          _switchTile(
            context: context,
            icon: Icons.dark_mode_outlined,
            title: 'Dark mode',
            subtitle: darkMode
                ? 'Tmavý režim je zapnutý'
                : 'Tmavý režim je vypnutý',
            value: darkMode,
            onChanged: (v) async {
              if (_themeLock) return;

              setState(() {
                _themeLock = true;
                darkMode = v;
              });

              // ⚡ okamžitý switch
              AppTheme.setDarkFast(v);

              // 💾 uloženie (debounce)
              await AppTheme.persistDarkDebounced(v);

              if (!mounted) return;
              setState(() => _themeLock = false);
            },
          ),

          /// 🔔 Notifications (permission dialog)
          _switchTile(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Upozornenia',
            subtitle: notifications
                ? 'Dostávať pripomienky a novinky'
                : 'Notifikácie sú vypnuté',
            value: notifications,
            onChanged: (v) async {
              // optimisticky prepni UI, ale keď permission zlyhá, vrátime späť
              setState(() => notifications = v);
              await _handleNotificationsToggle(v);
            },
          ),

          /// 📳 Vibrácie
          _switchTile(
            context: context,
            icon: Icons.vibration,
            title: 'Vibrácie',
            subtitle: vibrations ? 'Vibrácie sú zapnuté' : 'Vibrácie sú vypnuté',
            value: vibrations,
            onChanged: (v) async {
              setState(() => vibrations = v);
              await _saveBool('vibrations', v);
            },
          ),

          const SizedBox(height: 24),

          /// 📄 Privacy & Terms
          NeonCard(
            color: AppTokens.cardDark,
            shadows: AppTokens.tileShadow,
            padding: const EdgeInsets.all(14),
            child: ListTile(
              leading: const Icon(
                Icons.privacy_tip_outlined,
                color: AppTokens.emerald500,
              ),
              title: Text(
                'Privacy Policy & Terms',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'Informácie o ochrane súkromia a podmienkach používania',
                style: TextStyle(color: subtitleColor, fontSize: 13.5),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: subtitleColor,
              ),
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
