import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'core/theme/app_theme.dart';

class LeakCheckerScreen extends StatefulWidget {
  final void Function(int, String) changeTab;

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
      if (!_isValidEmail(data)) {
        showError('Formato de email inválido.');
        return;
      }
      await _checkEmailLeak(data);
    } else {
      if (data.length < 6) {
        showError('Senha muito curta. Pelo menos 6 caracteres.');
        return;
      }
      await _checkPasswordLeak(data);
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void showError(String message) {
    setState(() => resultMessage = '❌ $message');
  }

  Future<void> _checkPasswordLeak(String password) async {
    setState(() {
      isLoading = true;
      resultMessage = '';
    });
    final sha1Hash =
        sha1.convert(utf8.encode(password)).toString().toUpperCase();
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
            resultMessage =
                '⚠️ Sua senha foi encontrada em vazamentos (${parts[1]} vezes).';
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
    setState(() => isLoading = false);
    if (resultMessage.contains('⚠️')) _showHelpPopup(resultMessage);
  }

  Future<void> _checkEmailLeak(String email) async {
    setState(() {
      isLoading = true;
      resultMessage = '';
    });
    await Future.delayed(const Duration(milliseconds: 300)); // simulação
    if (email.endsWith('@test.com') || email.contains('leak')) {
      setState(() {
        resultMessage = '⚠️ O email $email foi encontrado em vazamentos!';
      });
    } else {
      setState(() {
        resultMessage = '✅ O email $email NÃO foi encontrado em vazamentos!';
      });
    }
    setState(() => isLoading = false);
    if (resultMessage.contains('⚠️')) _showHelpPopup(resultMessage);
  }

  void _showHelpPopup(String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                'Vazamento detectado! Deseja falar com o assistente?',
                style: TextStyle(color: AppTheme.textColor),
              ),
            ),
            TextButton(
              onPressed: () {
                scaffold.hideCurrentSnackBar();
                final autoMsg = selectedType == 'Email'
                    ? 'Meu email vazou, o que posso fazer?'
                    : 'Minha senha vazou, o que posso fazer?';
                widget.changeTab(0, autoMsg);
              },
              child: Text('Sim',
                  style: TextStyle(color: AppTheme.primaryColor)),
            ),
            TextButton(
              onPressed: scaffold.hideCurrentSnackBar,
              child: Text('Não',
                  style: TextStyle(color: AppTheme.textColor)),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 30, right: 16, left: 80),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final leftPadding = width * 0.0400; // ~35px em telas de 400px

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Título ‹Vazamento. /> posicionado responsivamente
            Padding(
              padding:
                  EdgeInsets.only(left: leftPadding, bottom: 40.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '<Vazamento. />',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Container principal
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppTheme.boxColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Label informativa
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'Digite o dado a ser verificado',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Campo de input
                  TextField(
                    controller: _dataController,
                    enabled: !isLoading,
                    style: TextStyle(color: AppTheme.textColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                      prefixIcon: Icon(
                        selectedType == 'Email'
                            ? Icons.email
                            : Icons.lock,
                        color: AppTheme.primaryColor,
                      ),
                      hintText: selectedType == 'Email'
                          ? 'Digite seu email'
                          : 'Digite sua senha',
                      hintStyle: TextStyle(
                          color: AppTheme.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: selectedType == 'Senha',
                  ),

                  const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: selectedType,


                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',    
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                ),

                dropdownColor: AppTheme.backgroundColor,
                iconEnabledColor: AppTheme.primaryColor,

                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),

                  // HintStyle (caso use hintText)
                  hintStyle: const TextStyle(
                    fontFamily: 'JetBrainsMono', 
                    color: AppTheme.primaryColor,
                  ),
                ),

                items: ['Email', 'Senha'].map((v) {
                  return DropdownMenuItem<String>(
                    value: v,
                    child: Text(
                      v,
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        color: AppTheme.primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),

                onChanged: (v) {
                  setState(() {
                    selectedType = v!;
                    resultMessage = '';
                  });
                },
              ),

                  const SizedBox(height: 20),

                  // Botão de verificação com gradiente
                  ElevatedButton(
                    onPressed: isLoading ? null : verifyData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        height: 48,
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  color: AppTheme.textColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                '🔍 Verificar',
                                style: TextStyle(
                                  color: AppTheme.textColor,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Mensagem de resultado
                  if (resultMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        resultMessage,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
