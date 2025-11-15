import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        //O Provider de Autenticação
        ChangeNotifierProvider(create: (_) => AuthService()),

        //o proxy provider out o AuthService 1 e depois cria o FireStoreService.
        ProxyProvider<AuthService, FirestoreService?>(
          // O 'create' é chamado uma vez
          create: (context) => null,

          //update é chamado toda vez que o AuthService mudar
          update: (context, auth, previousService) {
            // Se tiver um usuário logado (auth.usuario != null) ele cria o FirestoreService com uid
            if (auth.usuario != null) {
              return FirestoreService(uid: auth.usuario!.uid);
            }
            return null;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Abastecimento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      //Lógica da home para redirecionar o usuário!
      home: Consumer<AuthService>(
        builder: (context, auth, child) {
          //Se estiver verificando o login, mostra um loading
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          //Se não tem usuário logado, manda pro Login
          if (auth.usuario == null) {
            return const LoginScreen();
          }
          //Se tem usuário logado, manda pra Home
          return const HomeScreen();
        },
      ),
    );
  }
}
