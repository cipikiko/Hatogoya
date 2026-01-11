import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vibration/vibration.dart';
import 'screens/home_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'game/game_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/plants_screen.dart';

import 'services/auth_service.dart';
import 'services/prefs_service.dart';
import 'services/haptics_service.dart';
import 'services/lang_service.dart';

import 'theme/app_theme.dart';
import 'theme/tokens.dart';
import 'widgets/neon.dart';
import 'lang/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppTheme.load();
  await LangService.load();
  runApp(const BotanikApp());

}

class BotanikApp extends StatelessWidget {
  const BotanikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.mode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LangService.locale,
          builder: (context, loc, __) {
            return LangProvider(
              code: loc.languageCode,
              child: MaterialApp(
                title: 'Botanik',
                debugShowCheckedModeBanner: false,
                initialRoute: '/',
                routes: {
                  '/': (_) => const SplashScreen(),
                  '/main': (_) => const MainScreen(),
                },
                themeMode: mode,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,

                locale: loc,
                supportedLocales: const [
                  Locale('sk'),
                  Locale('en'),
                  Locale('nl'),
                ],

                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              ),

            );
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<NavigatorState> _shellNavKey = GlobalKey<NavigatorState>();
  int _selectedIndex = 0;

  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final t = await AuthService.getToken();
    setState(() => _token = t);
  }

  Future<void> _logout() async {
    final nav = Navigator.of(context);
    await AuthService.clearToken();
    if (!mounted) return;
    setState(() => _token = null);
    if (nav.canPop()) nav.pop();
    nav.pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  final List<Widget> _tabs = const [
    HomeScreen(),
    DiscoverScreen(),
    GameScreen(),
    PlantsScreen(),
  ];

  Future<void> _onItemTapped(int index) async {
    if (index == 4) {
      _showBottomMenu(context);
      return;
    }

    if (index != _selectedIndex) {
      final vibEnabled = await PrefsService.vibrationsEnabled();
      if (vibEnabled) {
        final hasVibrator = await Vibration.hasVibrator();

        if (hasVibrator) {
          Vibration.vibrate(duration: 18);
        } else {
          HapticFeedback.selectionClick();
        }
      }
    }

    setState(() {
      _selectedIndex = index;
      _shellNavKey.currentState?.popUntil((r) => r.isFirst);
    });
  }

  void _pushInShell(Widget screen) {
    _shellNavKey.currentState?.push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showBottomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusLg),
        ),
      ),
      builder: (context) {
        final mq = MediaQuery.of(context);
        final tr = context.tr;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mq.size.height * 0.7),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTokens.panelGradient(),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTokens.radiusLg),
              ),
              border: Border.all(color: AppTokens.cardBorder, width: 1),
              boxShadow: AppTokens.glow(AppTokens.green400, blur: 18, alpha: .14),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 12 + mq.padding.bottom),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTokens.handle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 12),

                    if (_token != null) ...[
                _MenuTile(
                label: tr.menuProfile,
                onTap: () {
                  Navigator.pop(context);
                  _pushInShell(const ProfileScreen());
                },
              ),
                _MenuTile(
                  label: tr.menuLogout,
                  onTap: _logout,
                ),
                ],

                if (_token == null) ...[
            _MenuTile(
            label: tr.menuLogin,
            onTap: () {
              Navigator.pop(context);
              _pushInShell(const LoginScreen());
            },
          ),
            _MenuTile(
              label: tr.menuRegister,
              onTap: () {
                Navigator.pop(context);
                _pushInShell(const RegisterScreen());
              },
            ),
            ],

            Divider(color: AppTokens.divider),

        _MenuTile(
        label: tr.menuSettings,
        onTap: () {
        Navigator.pop(context);
        _pushInShell(const SettingsScreen());
        },
        ),
        _MenuTile(
        label: tr.menuAbout,
        onTap: () {
        Navigator.pop(context);
        _pushInShell(const AboutScreen());
        },
        ),

                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _pngItem(
      String asset, {
        double size = 26,
        double activeSize = 28,
      }) =>
      BottomNavigationBarItem(
        icon: SizedBox(
          width: size,
          height: size,
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
        activeIcon: SizedBox(
          width: activeSize,
          height: activeSize,
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
        label: '',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(42),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 55,
              decoration: BoxDecoration(gradient: AppTokens.tealGradient),
            ),
            Container(height: 1, color: AppTokens.headerSeparator),
          ],
        ),
      ),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppTheme.mode,
        builder: (context, mode, _) {
          return Navigator(
            key: _shellNavKey,
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => KeyedSubtree(
                key: ValueKey(mode),
                child: _tabs[_selectedIndex],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppTokens.navBg,
            border: Border(top: BorderSide(color: AppTokens.navBorder, width: 1)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex,
            selectedItemColor: AppTokens.emerald500,
            unselectedItemColor: AppTokens.navUnselected,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
            selectedIconTheme: const IconThemeData(size: 28),
            unselectedIconTheme: const IconThemeData(size: 26),
            items: [
              _pngItem('lib/utils/images/home.png'),
              _pngItem('lib/utils/images/loupe.png'),
              _pngItem('lib/utils/images/gps.png', size: 30, activeSize: 34),
              _pngItem('lib/utils/images/plant.png'),
              _pngItem('lib/utils/images/filter.png'),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MenuTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      color: AppTokens.cardSurface,
      shadows: AppTokens.tileShadow,
      radius: AppTokens.radiusMd,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -1, horizontal: -1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: Text(
          label,
          style: TextStyle(fontSize: 15, color: AppTokens.textPrimary),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTokens.textSecondary,
          size: 20,
        ),
        onTap: () async {
          await HapticsService.tap();
          onTap();
        },
      ),
    );
  }
}
