import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color purple = const Color(0xFF9F45FF);
  final Color bg = const Color(0xFF0D0D0D);
  final Color darkCard = const Color(0xFF1A1A1A);

  String? nomeUsuario;

  @override
  void initState() {
    super.initState();
    _carregarNomeUsuario();
  }

  Future<void> _carregarNomeUsuario() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            nomeUsuario = data['nome'] ?? 'Usuário';
          });
        }
      } else {
        setState(() {
          nomeUsuario = 'Usuário';
        });
      }
    } else {
      setState(() {
        nomeUsuario = 'Usuário';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Row(
              children: [
                Icon(Icons.play_arrow, color: purple),
                const SizedBox(width: 8),
                Text(
                  'Bem-vindo de volta ${nomeUsuario ?? ''}',
                  style: TextStyle(color: purple, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // CARD DO CURSO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkCard,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Continuar curso?',
                              style: TextStyle(
                                color: Color(0xFF9F45FF),
                                fontSize: 18,
                                fontFamily: 'JetBrainsMono',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Fire Wall\nMódulo 1 - atividade 5',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.local_fire_department,
                        color: purple,
                        size: 48,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.play_arrow, color: Color(0xFF9F45FF)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 10,
                          child: LinearProgressIndicator(
                            value: 0.5,
                            backgroundColor: const Color.fromARGB(255, 231, 230, 230),
                            valueColor: AlwaysStoppedAnimation<Color>(purple),
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // CARDS DE NOTIFICAÇÕES E ALERTAS
            Row(
              children: [
                Expanded(
                  child: CardInfo(
                    title: 'Você tem',
                    value: '9+',
                    subtitle: 'Notificações',
                    color: purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CardInfo(
                    title: 'Você tem',
                    value: '1',
                    subtitle: 'Alerta de segurança',
                    color: purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// COMPONENTE REUTILIZÁVEL PARA OS CARDS DE INFO
class CardInfo extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const CardInfo({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
