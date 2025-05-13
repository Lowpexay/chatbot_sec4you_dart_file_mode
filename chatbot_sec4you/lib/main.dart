import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'chat_screen.dart';
import 'leak_check_screen.dart';
import 'local_data.dart';
import 'boards_screen.dart';
import 'board_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// Future<void> clearPrefs() async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.clear();
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await clearPrefs(); // Use await aqui!
  await dotenv.load();
  await LocalData().init();
  runApp(const Sec4YouApp());
}


class Sec4YouApp extends StatelessWidget {
  const Sec4YouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sec4You',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          iconTheme: IconThemeData(color: Color(0xFFFAF9F6)),
          titleTextStyle: TextStyle(
            color: Color(0xFFFAF9F6),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String _autoMessage = '';

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _autoMessage = '';
    });
  }

  void _changeTab(int index, String autoMsg) {
    setState(() {
      _selectedIndex = index;
      _autoMessage = autoMsg;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ChatScreen(initialMessage: _autoMessage),
      LeakCheckerScreen(changeTab: _changeTab),
      BoardsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: const Color(0xFF7F2AB1),
        unselectedItemColor: const Color(0xFFFAF9F6),
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Vazamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Fórum',
          ),
        ],
      ),
    );
  } 
}