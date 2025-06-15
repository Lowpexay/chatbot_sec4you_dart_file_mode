import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/leak_styles.dart';

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
              child: Text('Vazamento detectado! Deseja falar com o assistente?'),
            ),
            TextButton(
              onPressed: () {
                scaffold.hideCurrentSnackBar();
                final autoMsg = selectedType == 'Email'
                    ? 'Meu email vazou, o que posso fazer?'
                    : 'Minha senha vazou, o que posso fazer?';
                widget.changeTab(0, autoMsg);
              },
              child: const Text('Sim'),
            ),
            TextButton(
              onPressed: scaffold.hideCurrentSnackBar,
              child: const Text('Não'),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 30, right: 16, left: 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final leftPadding = width * 0.04;

    return Scaffold(
      backgroundColor: LeakStyles.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        padding: LeakStyles.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: LeakStyles.titlePadding.add(EdgeInsets.only(left: leftPadding)),
              child: Text('<Vazamento. />', style: LeakStyles.titleText),
            ),
            Container(
              padding: LeakStyles.containerPadding,
              decoration: BoxDecoration(
                color: LeakStyles.box,
                borderRadius: LeakStyles.containerRadius,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: LeakStyles.labelPadding,
                    child: Text(
                      'Digite o dado a ser verificado',
                      style: LeakStyles.labelText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextField(
                    controller: _dataController,
                    enabled: !isLoading,
                    style: TextStyle(color: LeakStyles.text),
                    decoration: LeakStyles.fieldDecoration(
                      icon: Icon(selectedType == 'Email' ? Icons.email : Icons.lock, color: LeakStyles.primary),
                      hint: selectedType == 'Email' ? 'Digite seu email' : 'Digite sua senha',
                    ),
                    obscureText: selectedType == 'Senha',
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    style: LeakStyles.labelText.copyWith(fontFamily: 'JetBrainsMono'),
                    decoration: LeakStyles.fieldDecoration(
                      icon: const Icon(Icons.arrow_drop_down),
                      hint: '',
                    ),
                    dropdownColor: LeakStyles.background,
                    iconEnabledColor: LeakStyles.primary,
                    items: ['Email', 'Senha'].map((v) =>
                      DropdownMenuItem(value: v, child: Text(v, style: LeakStyles.labelText.copyWith(fontFamily: 'JetBrainsMono')))
                    ).toList(),
                    onChanged: (v) => setState(() {
                      selectedType = v!;
                      resultMessage = '';
                    }),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : verifyData,
                    style: LeakStyles.gradientButtonStyle,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [LeakStyles.primary, LeakStyles.primary]),
                        borderRadius: LeakStyles.buttonRadius,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        height: 48,
                        child: isLoading
                          ? SizedBox(
                              width: LeakStyles.loaderSize,
                              height: LeakStyles.loaderSize,
                              child: CircularProgressIndicator(
                                color: LeakStyles.text,
                                strokeWidth: LeakStyles.loaderStrokeWidth,
                              ),
                            )
                          : Text('🔍 Verificar', style: LeakStyles.buttonText),
                      ),
                    ),
                  ),
                  if (resultMessage.isNotEmpty)
                    Padding(
                      padding: LeakStyles.resultPadding,
                      child: Text(resultMessage, style: LeakStyles.resultText, textAlign: TextAlign.center),
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
