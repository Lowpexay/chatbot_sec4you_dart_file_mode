import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.initialMessage});
  final String? initialMessage;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage?.isNotEmpty ?? false) {
      sendMessage(widget.initialMessage!);
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isLoading) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      isLoading = true;
    });

    final apiKey = dotenv.env['API_KEY'] ?? '';
    final response = await http.post(
      Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": "📩 Mensagem do usuário: $text"}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final aiText = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'Sem resposta.';
      setState(() => messages.add({"sender": "ai", "text": aiText}));
    } else {
      setState(() => messages.add({"sender": "ai", "text": "Erro ao se comunicar. 😢"}));
    }

    setState(() {
      isLoading = false;
      _controller.clear();
    });

    await Future.delayed(const Duration(milliseconds: 300));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  Widget buildMessage(Map<String, String> msg) {
    final isUser = msg['sender'] == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.boxColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            msg['text'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'JetBrainsMono',
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // permite a navbar ficar flutuando
      backgroundColor: AppTheme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                "<Chat Bot./>",
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
            ),
          ),
        ),
      ),
body: Padding(
  padding: const EdgeInsets.only(bottom: 90), // reserva espaço para a navbar
  child: Column(
    children: [
      Expanded(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: messages.length,
          itemBuilder: (context, index) => buildMessage(messages[index]),
        ),
      ),

      // Campo de input com espaçamento embutido
      Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
        child: TextField(
          controller: _controller,
          enabled: !isLoading,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontFamily: 'JetBrainsMono',
          ),
          onSubmitted: (_) => sendMessage(_controller.text),
          decoration: InputDecoration(
            hintText: isLoading ? "Aguarde a resposta..." : "Digite Aqui...",
            hintStyle: const TextStyle(
              color: AppTheme.primaryColor,
              fontFamily: 'JetBrainsMono',
            ),
            filled: true,
            fillColor: AppTheme.boxColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: isLoading ? null : () => sendMessage(_controller.text),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: AppTheme.textColor),
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minHeight: 40, minWidth: 40),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    ],
  ),
),



    );
  }
}
