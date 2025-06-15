import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_styles.dart';
import 'chat_screen.dart';
import 'leak_check_screen.dart';
import 'local_data.dart';
import 'boards_screen.dart';
import 'navbar.dart';
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
    const Center(child: Text('Guide Screen')),
    ChatScreen(initialMessage: _autoMessage),
    LeakCheckerScreen(changeTab: _changeTab),
    const Center(child: Text('Profile Screen')),
  ];

return Scaffold(
  
  extendBody: true, // permite blur/transparência abaixo da navbar
  body: screens[_selectedIndex],
  bottomNavigationBar: Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20), // afasta do fundo
    child: CustomNavBar(
    currentIndex: _selectedIndex,
    onTap: _onTabTapped,
    ),
  ),

  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
);
}
}
