import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/abastecimento.dart';
import '../models/veiculo.dart';
import '../services/firestore_service.dart';

class AddAbastecimentoScreen extends StatefulWidget {
  const AddAbastecimentoScreen({super.key});

  @override
  State<AddAbastecimentoScreen> createState() => _AddAbastecimentoScreenState();
}

class _AddAbastecimentoScreenState extends State<AddAbastecimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para os campos
  final _kmController = TextEditingController();
  final _litrosController = TextEditingController();
  final _valorController = TextEditingController();
  final _obsController = TextEditingController();

  // Variáveis de estado para data e veículo
  DateTime? _dataSelecionada = DateTime.now();
  Veiculo? _veiculoSelecionado;

  // Função para mostrar o calendário
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada!,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (data != null && data != _dataSelecionada) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  // Função principal para salvar
  Future<void> _salvarAbastecimento() async {
    // Validar o formulário
    if (!_formKey.currentState!.validate()) return;
    // Validar se data e veículo foram selecionados
    if (_veiculoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, selecione um veículo."), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);

      // Cria o objeto Abastecimento
      final novoAbastecimento = Abastecimento(
        veiculoId: _veiculoSelecionado!.id!,
        tipoCombustivel: _veiculoSelecionado!.tipoCombustivel, // Pega do veículo
        data: _dataSelecionada!,
        quilometragem: double.parse(_kmController.text.replaceAll(',', '.')),
        quantidadeLitros: double.parse(_litrosController.text.replaceAll(',', '.')),
        valorPago: double.parse(_valorController.text.replaceAll(',', '.')),
        observacao: _obsController.text.isEmpty ? null : _obsController.text,
        // Consumo será nulo por enquanto (Bônus Etapa 6)
      );

      // Salvar no Firebase
      await firestoreService.addAbastecimento(novoAbastecimento);

      // Feedback e fechar a tela
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Abastecimento salvo!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao salvar: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.watch<FirestoreService?>();

    if (firestoreService == null) {
      return const Scaffold(body: Center(child: Text("Erro: Serviço indisponível.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Abastecimento"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // O StreamBuilder busca os veículos para o Dropdown
        child: StreamBuilder<List<Veiculo>>(
          stream: firestoreService.getVeiculosStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final veiculos = snapshot.data!;

            if (veiculos.isEmpty) {
              return Center(
                child: Text(
                  "Você precisa cadastrar um veículo antes de registrar um abastecimento.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }
            
            // O Formulário só é construído se houver veículos
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Veiculo>(
                    value: _veiculoSelecionado,
                    decoration: const InputDecoration(
                      labelText: "Selecione o Veículo",
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text("Selecione..."),
                    items: veiculos.map((veiculo) {
                      return DropdownMenuItem<Veiculo>(
                        value: veiculo,
                        child: Text("${veiculo.marca} ${veiculo.modelo} (${veiculo.placa})"),
                      );
                    }).toList(),
                    onChanged: (Veiculo? veiculo) {
                      setState(() {
                        _veiculoSelecionado = veiculo;
                      });
                    },
                    validator: (veiculo) => veiculo == null ? 'Selecione um veículo' : null,
                  ),
                  const SizedBox(height: 16),

                  //data
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(color: Colors.grey.shade600),
                    ),
                    leading: const Icon(Icons.calendar_today),
                    title: const Text("Data do Abastecimento"),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada!)),
                    onTap: () => _selecionarData(context),
                  ),
                  const SizedBox(height: 16),
                  
                  //Campos numericos
                  TextFormField(
                    controller: _kmController,
                    decoration: const InputDecoration(labelText: "Quilometragem (Km)", border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
                    validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _litrosController,
                    decoration: const InputDecoration(labelText: "Quantidade (Litros)", border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
                    validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _valorController,
                    decoration: const InputDecoration(labelText: "Valor Pago (R\$)", border: OutlineInputBorder(), prefixText: "R\$ "),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
                    validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),

                  // Observacao
                  TextFormField(
                    controller: _obsController,
                    decoration: const InputDecoration(labelText: "Observação (Opcional)", border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // botao salvar
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _salvarAbastecimento,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
                          child: const Text("SALVAR ABASTECIMENTO"),
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}