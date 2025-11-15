import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  // Instância do Firebase Auth (é a ferramenta oficial do Google)
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variável para ver se tem alguem on no momento
  User? usuario;
  // Controla loading
  bool isLoading = true;

  AuthService() {
    _authProcuraUsuario();
  }
  // Verifica se tem alguem logado
  void _authProcuraUsuario() {
    _auth.authStateChanges().listen((User? user) {
      usuario = user;
      isLoading = false;
      notifyListeners(); // Mostra na tela a alteração do status
    });
  }
  // Login com email e senha
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Erro
      throw AuthException(e.code);
    }
  }
  // Cadastro email e senha
  Future<void> cadastrar(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code);
    }
  }
  // logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
// tradutor de erros
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}