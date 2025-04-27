import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';

class LeakCheckerScreen extends StatefulWidget {
  final Function(int, String) changeTab; // Função para mudar de aba

  const LeakCheckerScreen({super.key, required this.changeTab});

  @override
  State<LeakCheckerScreen> createState() => _LeakCheckerScreenState();
}

class _LeakCheckerScreenState extends State<LeakCheckerScreen> {
  final TextEditingController _dataController = TextEditingController();
  String selectedType = 'Email';
  String resultMessage = '';
  bool isLoading = false;

  Future<void> verifyData() async {
    final data = _dataController.text.trim();

    if (data.isEmpty) {
      showError('Digite algo para verificar.');
      return;
    }

    if (selectedType == 'Email') {
      if (!isValidEmail(data)) {
        showError('Formato de email inválido.');
        return;
      }
      await checkEmailLeak(data);
    } else if (selectedType == 'Senha') {
      if (data.length < 6) {
        showError('Senha muito curta. Pelo menos 6 caracteres.');
        return;
      }
      await checkPasswordLeak(data);
    }
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void showError(String message) {
    setState(() {
      resultMessage = '❌ $message';
    });
  }

  Future<void> checkPasswordLeak(String password) async {
    setState(() {
      isLoading = true;
      resultMessage = '';
    });

    final sha1Hash = sha1.convert(utf8.encode(password)).toString().toUpperCase();
    final prefix = sha1Hash.substring(0, 5);
    final suffix = sha1Hash.substring(5);

    final url = Uri.parse('https://api.pwnedpasswords.com/range/$prefix');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final hashes = response.body.split('\n');
      bool found = false;

      for (var line in hashes) {
        final parts = line.split(':');
        if (parts[0] == suffix) {
          found = true;
          setState(() {
            resultMessage = '⚠️ Sua senha foi encontrada em vazamentos (${parts[1]} vezes).';
          });
          break;
        }
      }

      if (!found) {
        setState(() {
          resultMessage = '✅ Sua senha NÃO foi encontrada em vazamentos!';
        });
      }
    } else {
      setState(() {
        resultMessage = '❌ Erro ao consultar a senha.';
      });
    }

    setState(() {
      isLoading = false;
    });

    if (resultMessage.contains('⚠️')) {
      showHelpPopup(resultMessage);
    }
  }

  Future<void> checkEmailLeak(String email) async {
    setState(() {
      isLoading = true;
      resultMessage = '';
    });

    // Simulação de vazamento de email
    if (email.endsWith('@test.com') || email.contains('leak')) {
      setState(() {
        resultMessage = '⚠️ O email $email foi encontrado em vazamentos!';
      });
    } else {
      setState(() {
        resultMessage = '✅ O email $email NÃO foi encontrado em vazamentos!';
      });
    }

    setState(() {
      isLoading = false;
    });

    if (resultMessage.contains('⚠️')) {
      showHelpPopup(resultMessage);
    }
  }

  void showHelpPopup(String message) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Vazamento Detectado! Deseja conversar com o assistente?',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              scaffold.hideCurrentSnackBar();
              String autoMsg = selectedType == 'Email'
                  ? "Meu email vazou, o que posso fazer?"
                  : "Minha senha vazou, o que posso fazer?";
              widget.changeTab(0, autoMsg);
            },
            child: const Text('Sim', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              scaffold.hideCurrentSnackBar();
            },
            child: const Text('Não', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF4b0082),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.only(bottom: 30, right: 16, left: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(seconds: 8),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2d004d),
      appBar: AppBar(
        title: const Text('Verificar Vazamentos'),
        backgroundColor: const Color(0xFF4b0082),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedType,
              dropdownColor: const Color(0xFF4b0082),
              iconEnabledColor: Colors.white,
              items: <String>['Email', 'Senha'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedType = newValue!;
                  resultMessage = '';
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _dataController,
              enabled: !isLoading,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  selectedType == 'Email' ? Icons.email : Icons.lock,
                  color: Colors.white,
                ),
                hintText: selectedType == 'Email'
                    ? 'Digite seu email'
                    : 'Digite sua senha',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF3e206b),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              obscureText: selectedType == 'Senha',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : verifyData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6a0dad),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verificar', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            if (resultMessage.isNotEmpty)
              Text(
                resultMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );

  }
}