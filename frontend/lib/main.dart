import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/plants_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/profile_screen.dart';
import 'game/game_screen.dart'; // 🎮 nová cesta
import 'widgets/custom_drawer.dart';
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

          // ☀️ Svetlá téma
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
            cardColor: Colors.white,
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              hintStyle: const TextStyle(color: AppColors.textGrey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.black87),
            ),
            useMaterial3: true,
          ),

          // 🌙 Tmavá téma
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1B1B1B), // 🔆 mierne svetlejšie
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF202020),
              foregroundColor: Colors.white,
            ),
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGreen,
              secondary: AppColors.secondaryGreen,
            ),
            cardColor: const Color(0xFF222222), // 🔆 jemne odlíšené od pozadia
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              hintStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Colors.white),
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

  // 🔥 Poradie stránok (Home, Discover, Challenges, Game, Plants, Profile)
  final List<Widget> _pages = const [
    HomeScreen(),
    DiscoverScreen(),
    ChallengesScreen(),
    GameScreen(), // 🎮 z lib/game/
    PlantsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Botanik'),
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
      drawer: const CustomDrawer(),
      body: _pages[_selectedIndex],

      // 🧭 Upravená spodná lišta
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222222) : const Color(0xFFF4F4F4),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.black54 : Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
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
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.sports_esports_outlined), label: ''), // 🎮
            BottomNavigationBarItem(icon: Icon(Icons.local_florist_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
          ],
        ),
      ),
    );
  }
}
