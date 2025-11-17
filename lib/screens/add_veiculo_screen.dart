import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/veiculo.dart';
import '../services/firestore_service.dart';
import 'package:flutter/services.dart';

class AddVeiculoScreen extends StatefulWidget {
  const AddVeiculoScreen({super.key});

  @override
  State<AddVeiculoScreen> createState() => _AddVeiculoScreenState();
}

class _AddVeiculoScreenState extends State<AddVeiculoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _modeloController = TextEditingController();
  final _marcaController = TextEditingController();
  final _placaController = TextEditingController();
  final _anoController = TextEditingController();

  String? _combustivelSelecionado;
  final List<String> _opcoesCombustivel = ['Álcool', 'Gasolina', 'Diesel', 'Flex (Gas/Álcool)'];

  bool _isLoading = false;

  // Salva formulario
  Future<void> _salvarVeiculo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Acessa o firestore
      final firestoreService = Provider.of<FirestoreService?>(
        context,
        listen: false,
      );

      if (firestoreService == null) {
        throw Exception("Usuário não autenticado. Serviço indisponível.");
      }

      //Criar o objeto Veiculo com os dados dos controladores
      final novoVeiculo = Veiculo(
        modelo: _modeloController.text,
        marca: _marcaController.text,
        placa: _placaController.text,
        ano: _anoController.text,
        tipoCombustivel: _combustivelSelecionado!,
      );

      //método de adicionar
      await firestoreService.addVeiculo(novoVeiculo);

      // Feedback e fecha
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veículo salvo com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Fecha a tela do formulário
      }
    } catch (e) {
      // aqui trata os erros
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao salvar veículo: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Validador simples
  String? _validadorCampoVazio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo é obrigatório';
    }
    return null;
  }

  //Valida o ano do carro
  String? _validadorAno(String? value) {
    // 1. Checa se está vazio
    if (value == null || value.isEmpty) {
      return 'Este campo é obrigatório';
    }

    // 2. Checa se é um número inteiro válido
    // (O inputFormatter já ajuda, mas a validação garante)
    final anoInt = int.tryParse(value);
    if (anoInt == null) {
      return 'Digite um ano válido (apenas números)';
    }
    if (value.length != 4) {
      return 'O ano deve ter 4 dígitos (ex: 2023)';
    }
    if (anoInt < 1900) {
      return 'O ano deve ser no mínimo 1900';
    }
    //Checa o ano máximo e coloca a regra de +1 ano pq existem carros que lançam com o numero do ano seguinte
    final int anoAtual = DateTime.now().year;
    if (anoInt > anoAtual + 1) {
      // +1 para permitir carros do "próximo ano"
      return 'O ano não pode ser maior que ${anoAtual + 1}';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar Novo Veículo")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //Campos formulario
                TextFormField(
                  controller: _modeloController,
                  decoration: const InputDecoration(
                    labelText: "Modelo",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                  validator: _validadorCampoVazio,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _marcaController,
                  decoration: const InputDecoration(
                    labelText: "Marca",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: _validadorCampoVazio,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _placaController,
                  decoration: const InputDecoration(
                    labelText: "Placa",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.pin),
                  ),
                  validator: _validadorCampoVazio,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _anoController,
                  decoration: const InputDecoration(
                    labelText: "Ano",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: _validadorAno,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _combustivelSelecionado,
                  decoration: const InputDecoration(
                    labelText: "Tipo de Combustível",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_gas_station),
                  ),
                  hint: const Text("Selecione..."),
                  // Mapeia a lista de strings para os itens do menu
                  items: _opcoesCombustivel.map((String valor) {
                    return DropdownMenuItem<String>(
                      value: valor,
                      child: Text(valor),
                    );
                  }).toList(),
                  // Atualiza a variável de estado quando o usuário escolhe
                  onChanged: (String? novoValor) {
                    setState(() {
                      _combustivelSelecionado = novoValor;
                    });
                  },
                  // Validador próprio para o dropdown
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecione um combustível';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // botao salvar
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _salvarVeiculo,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text("SALVAR VEÍCULO"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
