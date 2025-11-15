import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/veiculo.dart';
import '../services/firestore_service.dart';
import 'add_veiculo_screen.dart';

class VeiculosListScreen extends StatelessWidget {
  const VeiculosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //Acessa o FirestoreService
    final firestoreService = Provider.of<FirestoreService?>(context);

    // Se o usuário deslogar, o service fica nulo, mostra loading
    if (firestoreService == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Meus Veículos")),
      body: StreamBuilder<List<Veiculo>>(
        stream: firestoreService.getVeiculosStream(),
        builder: (context, snapshot) {
          // Estado de Carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estado de Erro
          if (snapshot.hasError) {
            return Center(
              child: Text("Erro ao carregar veículos: ${snapshot.error}"),
            );
          }

          // Pega a lista de veiculos
          final veiculos = snapshot.data;

          // Estado vazio sem veiculos
          if (veiculos == null || veiculos.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum veículo cadastrado.\nClique no '+' para adicionar.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // estado com dados mostrando lista
          return ListView.builder(
            itemCount: veiculos.length,
            itemBuilder: (context, index) {
              final veiculo = veiculos[index];

              return ListTile(
                leading: const Icon(Icons.directions_car_filled, size: 40),
                title: Text(
                  "${veiculo.marca} ${veiculo.modelo}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Placa: ${veiculo.placa} | Ano: ${veiculo.ano}"),
                //botão de Excluir
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // confirmação para excluir
                    _mostrarDialogoDeExclusao(
                      context,
                      firestoreService,
                      veiculo.id!,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      //botao flutuante para abrir o formulário
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVeiculoScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Função helper para confirmar a exclusão
  void _mostrarDialogoDeExclusao(
    BuildContext context,
    FirestoreService service,
    String veiculoId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content: const Text(
            "Tem certeza que deseja excluir este veículo? Esta ação não pode ser desfeita.",
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Excluir"),
              onPressed: () {
                service.deleteVeiculo(veiculoId);
                Navigator.of(ctx).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Veículo excluído.")),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
