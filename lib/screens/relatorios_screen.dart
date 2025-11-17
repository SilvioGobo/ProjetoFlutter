import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/abastecimento.dart';
import '../services/firestore_service.dart';

class RelatoriosScreen extends StatelessWidget {
  const RelatoriosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService?>(context);
    if (firestoreService == null) {
      return const Scaffold(body: Center(child: Text("Serviço indisponível")));
    }

    final Color corPrimaria = Theme.of(context).primaryColor;
    final Color corSecundaria = Colors.green.shade700;

    return Scaffold(
      appBar: AppBar(title: const Text("Relatório de Consumo (KM/L)")),
      body: StreamBuilder<List<Abastecimento>>(
        stream: firestoreService.getAbastecimentosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Sem dados para exibir."));
          }

          final List<Abastecimento> dadosConsumo = snapshot.data!
              .where((a) => a.consumo != null && a.consumo! > 0)
              .toList();

          dadosConsumo.sort((a, b) => a.data.compareTo(b.data));

          if (dadosConsumo.isEmpty) {
            return const Center(
              child: Text(
                "Você precisa de pelo menos 2 abastecimentos\npara o cálculo de consumo aparecer.",
                textAlign: TextAlign.center,
              ),
            );
          }

          // Acha o valor mais alto para o eixo Y
          double maxY = 10; // Valor mínimo do eixo
          if (dadosConsumo.isNotEmpty) {
            maxY = dadosConsumo
                .map((e) => e.consumo!)
                .reduce((a, b) => a > b ? a : b);
          }

          // Constrói a lista de barras
          final List<BarChartGroupData> barGroups = [];
          for (int i = 0; i < dadosConsumo.length; i++) {
            final item = dadosConsumo[i];
            barGroups.add(
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: item.consumo!,
                    gradient: LinearGradient(
                      colors: [corPrimaria, corSecundaria],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: 22,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2, // 20% de folga no topo

                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final consumo = rod.toY;
                      return BarTooltipItem(
                        '${consumo.toStringAsFixed(1)}\nKm/L',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),

                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: (maxY / 5).ceilToDouble(),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final int index = value.toInt();
                        if (index >= 0 && index < dadosConsumo.length) {
                          final String dataFormatada = DateFormat(
                            'dd/MM',
                          ).format(dadosConsumo[index].data);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dataFormatada,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY / 5).ceilToDouble(),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          );
        },
      ),
    );
  }
}
