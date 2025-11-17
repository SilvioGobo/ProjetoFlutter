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

  //Variaveis para veiculo FLEX
  String? _combustivelUsado; // Guarda "Álcool" ou "Gasolina" se for Flex
  bool _mostrarOpcaoFlex = false; // Controla a visibilidade do novo dropdown

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
        const SnackBar(
          content: Text("Por favor, selecione um veículo."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validação extra para o Flex
    if (_mostrarOpcaoFlex && _combustivelUsado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, selecione o combustível usado."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );

      // Se for Flex, usa o que o usuário selecionou.
      // Se não, usa o combustível padrão do veículo.
      final String combustivelFinal = _mostrarOpcaoFlex
          ? _combustivelUsado!
          : _veiculoSelecionado!.tipoCombustivel;

      //Lógica do calculo da media km/litro

      // Pegar os valores atuais do formulário
      final double kmAtual = double.parse(
        _kmController.text.replaceAll(',', '.'),
      );
      final double litros = double.parse(
        _litrosController.text.replaceAll(',', '.'),
      );

      // Busca o último abastecimento deste veículo
      final Abastecimento? ultimoAbastecimento = await firestoreService
          .getUltimoAbastecimento(_veiculoSelecionado!.id!);

      double? consumoCalculado;

      if (ultimoAbastecimento != null) {
        // km atual maior que o anterior ele calcula a media
        if (kmAtual > ultimoAbastecimento.quilometragem) {
          final double kmRodados = kmAtual - ultimoAbastecimento.quilometragem;
          if (litros > 0) {
            consumoCalculado = kmRodados / litros;
          }
        }
        // Se a KM atual for menor continua nulo
      }
      // Se for o primeiro abastecimento é nulo tbm

      // Cria o objeto Abastecimento
      final novoAbastecimento = Abastecimento(
        veiculoId: _veiculoSelecionado!.id!,
        tipoCombustivel:
            combustivelFinal, // Pega do veículo (feature flex nova add)
        data: _dataSelecionada!,
        quilometragem: kmAtual, //att para km/l
        quantidadeLitros: litros, //att para km/l
        valorPago: double.parse(_valorController.text.replaceAll(',', '.')),
        observacao: _obsController.text.isEmpty ? null : _obsController.text,
        consumo: consumoCalculado, //salva o calculo.
      );

      // Salvar no Firebase
      await firestoreService.addAbastecimento(novoAbastecimento);

      // Feedback e fechar a tela
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Abastecimento salvo!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao salvar: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
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
      return const Scaffold(
        body: Center(child: Text("Erro: Serviço indisponível.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Abastecimento")),
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
                        child: Text(
                          "${veiculo.marca} ${veiculo.modelo} (${veiculo.placa})",
                        ),
                      );
                    }).toList(),
                    onChanged: (Veiculo? veiculo) {
                      setState(() {
                        _veiculoSelecionado = veiculo;
                        //Se carro flex, mostra dropdown extra:
                        if (veiculo != null &&
                            veiculo.tipoCombustivel == 'Flex (Gas/Álcool)') {
                          _mostrarOpcaoFlex = true;
                        } else {
                          _mostrarOpcaoFlex = false;
                        }
                        _combustivelUsado = null; //reseta a seleção
                      });
                    },
                    validator: (veiculo) =>
                        veiculo == null ? 'Selecione um veículo' : null,
                  ),
                  const SizedBox(height: 16),
                  // Dropdown do carro flex
                  if (_mostrarOpcaoFlex)
                    DropdownButtonFormField<String>(
                      value: _combustivelUsado,
                      decoration: const InputDecoration(
                        labelText: "Combustível Utilizado",
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text("Selecione..."),
                      items: ['Álcool', 'Gasolina'].map((String valor) {
                        return DropdownMenuItem<String>(
                          value: valor,
                          child: Text(valor),
                        );
                      }).toList(),
                      onChanged: (String? novoValor) {
                        setState(() {
                          _combustivelUsado = novoValor;
                        });
                      },
                      validator: (value) => value == null ? 'Selecione' : null,
                    ),
                  if (_mostrarOpcaoFlex) const SizedBox(height: 16),

                  //data
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: BorderSide(color: Colors.grey.shade600),
                    ),
                    leading: const Icon(Icons.calendar_today),
                    title: const Text("Data do Abastecimento"),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(_dataSelecionada!),
                    ),
                    onTap: () => _selecionarData(context),
                  ),
                  const SizedBox(height: 16),

                  //Campos numericos
                  TextFormField(
                    controller: _kmController,
                    decoration: const InputDecoration(
                      labelText: "Quilometragem (Km)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _litrosController,
                    decoration: const InputDecoration(
                      labelText: "Quantidade (Litros)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _valorController,
                    decoration: const InputDecoration(
                      labelText: "Valor Pago (R\$)",
                      border: OutlineInputBorder(),
                      prefixText: "R\$ ",
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),

                  // Observacao
                  TextFormField(
                    controller: _obsController,
                    decoration: const InputDecoration(
                      labelText: "Observação (Opcional)",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // botao salvar
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _salvarAbastecimento,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
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
