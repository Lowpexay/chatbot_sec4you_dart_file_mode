import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      sendMessage(widget.initialMessage!);
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isLoading) return;

    setState(() {
      messages.add({"sender": "user", "text": text});
      isLoading = true;
    });

    final String apiKey = dotenv.env['API_KEY'] ?? '';
    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {
                "text": """
                Você é Luiz, assistente virtual da Sec4You, especializado apenas em temas de **segurança da informação**. Responda **em português brasileiro**.
                
                📌 **Instruções gerais:**
                - Seja objetivo e amigável, mas direto.
                - Não inicie toda mensagem com saudações como "Olá", "Oi", "Tudo bem?". Apenas a interação inicial.
                - Responda usando frases curtas e simples.
                - Não escreva mais do que o necessário para ser claro.
                
                🎭 **Tom emocional:**
                - Analise a mensagem do usuário e indique o tom no formato [TOM: feliz, bravo, triste, explicando, neutro] antes da resposta.
                
                🚫 **Assuntos fora do contexto:**
                - Se o tema não for relacionado à **segurança da informação**, responda apenas:
                  "Desculpe, não posso te ajudar com isso. Sobre o que de segurança você gostaria de saber?"
                
                📩 **Mensagem do usuário:**  
                $text
                """
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final aiText = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 'Sem resposta.';
      setState(() {
        messages.add({
          "sender": "ai",
          "text": aiText,
          "mood": "neutro",
        });
      });
    } else {
      setState(() {
        messages.add({
          "sender": "ai",
          "text": "Erro ao se comunicar com o assistente. 😢",
          "mood": "erro",
        });
      });
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
    bool isUser = msg['sender'] == "user";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF1A1A1A), // Cinza escuro
                child: const Icon(Icons.person, color: Color(0xFFFAF9F6)), // Branco
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF1A1A1A) : const Color(0xFF232323), // Cinza escuro / Cinza um pouco mais claro
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser ? const Radius.circular(0) : const Radius.circular(18),
                  bottomRight: isUser ? const Radius.circular(18) : const Radius.circular(0),
                ),
              ),
              child: Text(
                msg['text'] ?? '',
                style: const TextStyle(color: Color(0xFFFAF9F6), fontSize: 16), // Branco
              ),
            ),
          ),
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF232323), // Cinza um pouco mais claro
                backgroundImage: const AssetImage('assets/feliz.png'),
                radius: 20,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Preto/Cinza
      appBar: AppBar(
        title: const Text(
          "<Chat Bot./>",
          style: TextStyle(
            color: Color(0xFFFAF9F6), // Branco puro
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A), // Cinza escuro
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFFAF9F6)), // Ícones brancos
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) => buildMessage(messages[index]),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color(0xFF0D0D0D), // Preto/Cinza
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !isLoading,
                      style: const TextStyle(color: Color(0xFFFAF9F6)), // Branco
                      decoration: InputDecoration(
                        hintText: isLoading ? "Aguarde a resposta..." : "Digite sua mensagem...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A), // Cinza escuro
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => sendMessage(_controller.text),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: isLoading ? null : () => sendMessage(_controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7F2AB1), // Roxo claro
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.send, color: Color(0xFFFAF9F6)), // Branco
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF1A1A1A), // Cinza escuro
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: const Text(
          'Desenvolvido por Gabriel Gramacho, Mikael Palmeira, Gabriel Araujo e Kauã Granata • 2025',
          style: TextStyle(
            color: Color(0xFFFAF9F6), // Branco puro
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}