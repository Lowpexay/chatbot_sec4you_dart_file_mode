# Sec4You App

Aplicativo Flutter para segurança digital, com autenticação, chat, verificação de vazamentos, fórum e mapa de usuários.

## Funcionalidades

- **Autenticação de Usuário** (Firebase)
- **Chatbot** para dúvidas e suporte
- **Verificação de Vazamentos** de dados
- **Fórum** para discussões
- **Mapa de Usuários**
- **Logout Seguro**

## Estrutura

- `main.dart`: Ponto de entrada do app, navegação principal e tema.
- Telas: `HomeScreen`, `ChatScreen`, `LeakCheckerScreen`, `BoardsScreen`, `UsersMapScreen`
- Serviços: `AuthService` para autenticação

## Requisitos

- Flutter 3.x
- Firebase configurado
- Arquivo `.env` com variáveis de ambiente

## Instalação

1. Clone o repositório:
   ```sh
   git clone <url-do-repo>
   cd flutter_sec4you_app/chatbot_sec4you
