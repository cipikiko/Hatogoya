import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/plants_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/about_screen.dart';

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTokens.pageBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTokens.headerBg,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppTokens.emerald500,
          secondary: AppTokens.teal600,
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
    ChallengesScreen(),
    PlantsScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 4) {
      _showBottomMenu(context);
      return;
    }
    setState(() {
      _selectedIndex = index;
      // pri prepnutí tabu zavri prípadné vnútorné pushed stránky
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
              boxShadow: AppTokens.glow(AppTokens.teal400, blur: 22),
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

      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 6, bottom: 10),
        decoration: const BoxDecoration(
          color: AppTokens.navBg,
          border: Border(top: BorderSide(color: AppTokens.navBorder, width: 1)),
        ),
        child: SizedBox(
          height: 70,
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
            items: [
              BottomNavigationBarItem(
                icon: Image.asset('lib/utils/images/home.png', height: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('lib/utils/images/loupe.png', height: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('lib/utils/images/trophy.png', height: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('lib/utils/images/plant.png', height: 28),
                label: '',
              ),
              // spúšťač menu
              BottomNavigationBarItem(
                icon: Image.asset('lib/utils/images/filter.png', height: 28),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// položka v bottom-sheet menu (bez ľavého „štvorca“)
class _MenuTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MenuTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      color: AppTokens.cardDark,
      shadows: AppTokens.tileShadow,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(label, style: const TextStyle(color: AppTokens.textPrimary)),
        trailing: const Icon(Icons.chevron_right, color: AppTokens.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
