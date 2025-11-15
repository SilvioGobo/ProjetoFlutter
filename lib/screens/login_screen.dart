import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para pegar o texto digitado
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  // Variável para alternar entre "Modo Login" e "Modo Cadastro"
  bool isLogin = true;
  bool loading = false;

  // Título muda conforme o modo
  String get titulo => isLogin ? "Bem-vindo!" : "Crie sua conta";
  String get textoBotao => isLogin ? "ENTRAR" : "CADASTRAR";
  String get textoAlternar => isLogin ? "Cadastrar" : "Já tem conta? Entre";

  // Função responsável por chamar o AuthService
  Future<void> _cliqueDoBotao() async {
    setState(() => loading = true); // Ativa o carregamento (Loading)

    try {
      // 1. Chama o Provider para acessar nosso Serviço de Autenticação
      if (isLogin) {
        await context.read<AuthService>().login(
          _emailController.text,
          _senhaController.text,
        );
      } else {
        await context.read<AuthService>().cadastrar(
          _emailController.text,
          _senhaController.text,
        );
      }
      // Se passar daqui, significa que funcionou!
    } on AuthException catch (e) {
      // Erro com snackbar vermelha
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      // Erro genérico
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro inesperado: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // 3. Desativa o carregamento
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              //Utilizando os icones do tema
              Icon(Icons.local_gas_station, size: 120, color: Colors.red),
              const SizedBox(height: 20),

              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Campo de Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "E-mail",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.orangeAccent),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Campo de Senha
              TextFormField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.orangeAccent),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),

              // Botão Principal (Login ou Cadastro)
              loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: _cliqueDoBotao,
                      child: Text(textoBotao),
                    ),

              // Botão para trocar entre Login e Cadastro
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(textoAlternar),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
