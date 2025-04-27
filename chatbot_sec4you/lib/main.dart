import 'package:flutter/material.dart';
import 'leak_check_screen.dart';
import 'chat_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Security Connect',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _pendingMessage = '';

  late final ChatScreen _chatScreen;
  late final LeakCheckerScreen _leakCheckerScreen;

  @override
  void initState() {
    super.initState();
    _chatScreen = const ChatScreen();
    _leakCheckerScreen = LeakCheckerScreen(changeTab: _changeTab);
  }

  void _changeTab(int index, String message) {
    setState(() {
      _currentIndex = index;
      _pendingMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se houver mensagem pendente, crie uma nova instância do ChatScreen com a mensagem
    final List<Widget> _screens = [
      _pendingMessage.isNotEmpty
          ? ChatScreen(initialMessage: _pendingMessage)
          : _chatScreen,
      _leakCheckerScreen,
    ];

    // Limpa a mensagem pendente após exibir
    if (_pendingMessage.isNotEmpty && _currentIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _pendingMessage = '';
        });
      });
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.security), label: 'Verificar Dados'),
        ],
      ),
    );
  }
}