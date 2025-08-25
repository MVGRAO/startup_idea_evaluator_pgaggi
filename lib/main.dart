import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/idea_listing.dart';
import 'screens/idea_submission.dart';
import 'screens/leaderboard.dart';

void main() {
  runApp(const StartupApp());
}

class StartupApp extends StatefulWidget {
  const StartupApp({super.key});

  @override
  State<StartupApp> createState() => _StartupAppState();
}

class _StartupAppState extends State<StartupApp> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Idea Evaluator',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: MainNavigation(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3498DB),
        secondary: Color(0xFF2ECC71),
        surface: Color(0xFF34495E),
        background: Color(0xFF2C3E50),
      ),
      scaffoldBackgroundColor: const Color(0xFF2C3E50),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF34495E),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3498DB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF34495E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF3498DB),
        secondary: Color(0xFF2ECC71),
        surface: Colors.white,
        background: Color(0xFFECF0F1),
      ),
      scaffoldBackgroundColor: const Color(0xFFECF0F1),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF3498DB),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3498DB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const MainNavigation({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
        IdeaSubmissionScreen(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
          onNavigationChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        IdeaListingScreen(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
          onNavigationChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        LeaderboardScreen(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
          onNavigationChange: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: "Submit"),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: "Ideas"),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: "Leaderboard"),
        ],
      ),
    );
  }
}
