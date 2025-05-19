import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'chat_screen.dart';
import 'leak_check_screen.dart';
import 'local_data.dart';
import 'boards_screen.dart';
import 'navbar.dart'; // Import your custom navbar
import 'board_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      theme: AppTheme.darkTheme(),
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
      _autoMessage = ''; // Clear auto message on tab change
    });
    // Debug
    debugPrint('Tapped tab index: $index');
  }

  void _changeTab(int index, String autoMsg) {
    setState(() {
      _selectedIndex = index;
      _autoMessage = autoMsg;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screens = [
      ChatScreen(initialMessage: _autoMessage),     // Home tab
      const Center(child: Text('Guide Screen')),     // Guide tab (Placeholder)
      ChatScreen(initialMessage: _autoMessage),     // Robot tab (Placeholder)
      LeakCheckerScreen(changeTab: _changeTab),      // Security tab
      const Center(child: Text('Profile Screen')),   // Profile tab (Placeholder)
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(
          bottom: 20.0,
          left: 20.0,
          right: 20.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: CustomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}