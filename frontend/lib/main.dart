import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';
import 'game/game_screen.dart';

// theme helpers
import 'theme/tokens.dart';
import 'widgets/neon.dart';

void main() {
  runApp(const BotanikApp());
}

class BotanikApp extends StatelessWidget {
  const BotanikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Botanik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppTokens.pageBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTokens.headerBg,
          foregroundColor: AppTokens.greenDark,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.light(
          primary: AppTokens.emerald500,
          secondary: AppTokens.green600,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // vnútorný navigator pre obsah (telo) – bar ostáva
  final GlobalKey<NavigatorState> _shellNavKey = GlobalKey<NavigatorState>();

  int _selectedIndex = 0;

  // posledná položka v spodnej lište je spúšťač menu (nie tab)
  final List<Widget> _tabs = const [
    HomeScreen(),
    DiscoverScreen(),
    GameScreen(),
    ChallengesScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 4) {
      _showBottomMenu(context);
      return;
    }
    setState(() {
      _selectedIndex = index;
      _shellNavKey.currentState?.popUntil((r) => r.isFirst);
    });
  }

  // otvorenie obrazoviek v rámci shell navigátora (bar ostáva)
  void _pushInShell(Widget screen) {
    _shellNavKey.currentState?.push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  // Neon bottom sheet menu
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

                      _MenuTile(
                        label: 'Profil',
                        onTap: () {
                          Navigator.pop(context);
                          _pushInShell(const ProfileScreen());
                        },
                      ),
                      _MenuTile(
                        label: 'Prihlásiť sa',
                        onTap: () {
                          Navigator.pop(context);
                          _pushInShell(const LoginScreen());
                        },
                      ),
                      _MenuTile(
                        label: 'Registrovať sa',
                        onTap: () {
                          Navigator.pop(context);
                          _pushInShell(const RegisterScreen());
                        },
                      ),
                      const Divider(color: AppTokens.divider),
                      _MenuTile(
                        label: 'Nastavenia',
                        onTap: () {
                          Navigator.pop(context);
                          _pushInShell(const SettingsScreen());
                        },
                      ),
                      _MenuTile(
                        label: 'O aplikácii',
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

  // jednotný item pre PNG ikony v bare
  BottomNavigationBarItem _pngItem(String asset) => BottomNavigationBarItem(
    icon: SizedBox(
      width: 26,
      height: 26,
      child: Image.asset(asset, fit: BoxFit.contain),
    ),
    activeIcon: SizedBox(
      width: 28,
      height: 28,
      child: Image.asset(asset, fit: BoxFit.contain),
    ),
    label: '',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // horný pás so spoločným gradientom
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(42),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 55, decoration: BoxDecoration(gradient: AppTokens.tealGradient)),
            Container(height: 1, color: AppTokens.headerSeparator),
          ],
        ),
      ),

      // telo s vnútorným Navigatorom – bar ostáva viditeľný
      body: Navigator(
        key: _shellNavKey,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => _tabs[_selectedIndex],
        ),
      ),

      // spodná navigácia – bezpečná voči overflow vďaka SafeArea a bez fixnej výšky
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
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
              _pngItem('lib/utils/images/plant.png'),
              _pngItem('lib/utils/images/trophy.png'),
              _pngItem('lib/utils/images/filter.png'), // spúšťač menu
            ],
          ),
        ),
      ),
    );
  }
}

/// položka v bottom-sheet menu – o trochu väčšie bubliny, rozostupy zostanú vzdušné
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
          style: const TextStyle(fontSize: 15, color: AppTokens.textPrimary),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTokens.textSecondary,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
