import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar datas e moedas
import 'package:provider/provider.dart';
import '../models/abastecimento.dart';
import '../services/firestore_service.dart';

class HistAbastecimentosScreen extends StatelessWidget {
  const HistAbastecimentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService?>(context);

    if (firestoreService == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Formatação de Moeda
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    // Formatação de Data
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text("Histórico de Abastecimentos")),
      body: StreamBuilder<List<Abastecimento>>(
        stream: firestoreService.getAbastecimentosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum abastecimento registrado.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final abastecimentos = snapshot.data!;

          // O ListView com os dados
          return ListView.builder(
            itemCount: abastecimentos.length,
            itemBuilder: (context, index) {
              final item = abastecimentos[index];

              // preço por litro
              String precoPorLitro = "";
              if (item.quantidadeLitros > 0) {
                final double p = item.valorPago / item.quantidadeLitros;
                precoPorLitro = "(${currencyFormatter.format(p)}/L)";
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  child: Text(
                    item.tipoCombustivel[0], // "G", "A" ou "D"
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                title: Text(
                  currencyFormatter.format(item.valorPago),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${item.quantidadeLitros.toStringAsFixed(2)} L  $precoPorLitro\nEm: ${dateFormatter.format(item.data)} | ${item.quilometragem.toStringAsFixed(0)} Km",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Confirmação antes de excluir
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Confirmar Exclusão"),
                        content: const Text(
                          "Tem certeza que deseja excluir este registro?",
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Cancelar"),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          TextButton(
                            child: const Text("Excluir"),
                            onPressed: () {
                              firestoreService.deleteAbastecimento(item.id!);
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Registro excluído."),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
