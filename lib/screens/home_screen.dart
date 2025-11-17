import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'veiculos_list_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'add_abastecimento_screen.dart';
import 'hist_abastecimentos_screen.dart';
import 'relatorios_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pega o nome do usuário (do email) para o "Olá"
    final user = context.read<AuthService>().usuario;
    final String nomeUsuario = user?.email?.split('@').first ?? "Usuário";

    return Scaffold(
      appBar: AppBar(title: const Text("Página Inicial")),
      // drawer feito
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                nomeUsuario,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.orange),
              ),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text("Meus Veículos"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VeiculosListScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_gas_station),
              title: const Text("Registrar Abastecimento"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAbastecimentoScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Histórico de Abastecimentos"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistAbastecimentosScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text("Relatórios (Gráfico)"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RelatoriosScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Sair"),
              onTap: () {
                context.read<AuthService>().logout();
                Navigator.pop(context); // Fecha o drawer
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                "https://placehold.co/400x200/FF9800/FFFFFF?text=Controle+de+Combust%EDvel&font=roboto",
                height: 150,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, size: 100, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Text(
                "Olá, $nomeUsuario!",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Use o menu lateral (☰) para gerenciar seus veículos e abastecimentos.",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 18, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
