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
import 'utils/app_colors.dart';
import 'utils/theme_manager.dart';

void main() {
  runApp(const BotanikApp());
}

class BotanikApp extends StatelessWidget {
  const BotanikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Botanik',
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              secondary: AppColors.secondaryGreen,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1B1B1B),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF202020),
              foregroundColor: Colors.white,
            ),
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGreen,
              secondary: AppColors.secondaryGreen,
            ),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: const MainScreen(),
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
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    DiscoverScreen(),
    ChallengesScreen(),
    PlantsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index < _pages.length) {
      setState(() => _selectedIndex = index);
    } else {
      _showBottomMenu(context);
    }
  }

  // 🌿 Moderné menu ako v Duolingu
  void _showBottomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.primaryGreen),
              title: const Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.login, color: AppColors.primaryGreen),
              title: const Text('Prihlásiť sa'),
              onTap: () {
                Navigator.pop(context);
                _openScreen(const LoginScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: AppColors.primaryGreen),
              title: const Text('Registrovať sa'),
              onTap: () {
                Navigator.pop(context);
                _openScreen(const RegisterScreen());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primaryGreen),
              title: const Text('Nastavenia'),
              onTap: () {
                Navigator.pop(context);
                _openScreen(const SettingsScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.primaryGreen),
              title: const Text('O aplikácii'),
              onTap: () {
                Navigator.pop(context);
                _openScreen(const AboutScreen());
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _openScreen(Widget screen) {
    Future.delayed(
      const Duration(milliseconds: 150),
          () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 🌱 Gradientový header hore
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(42),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 55,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // 🔹 Svetlo sivá deliaca čiara pod headerom
            Container(
              height: 1.5,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),

      // 📱 Hlavný obsah
      body: _pages[_selectedIndex],

      // 🌿 Spodný navigačný bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 6, bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222222) : const Color(0xFFF4F4F4),
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade600, // 🔹 svetlo sivá deliaca čiara
              width: 1.5, // 🔹 trošku hrubšia
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -1),
              blurRadius: 3,
            ),
          ],
        ),
        child: SizedBox(
          height: 70,
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex,
            selectedItemColor: AppColors.primaryGreen,
            unselectedItemColor: Colors.grey,
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
              BottomNavigationBarItem(
                icon: Image.asset('lib/utils/images/user.png', height: 28),
                label: '',
              ),
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
