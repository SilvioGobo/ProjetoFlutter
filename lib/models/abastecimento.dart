import 'package:cloud_firestore/cloud_firestore.dart';

class Abastecimento {
  final String? id;
  
  final String veiculoId; // ID do documento do veículo associado
  final DateTime data;
  final double quantidadeLitros;
  final double valorPago;
  final double quilometragem;
  final String tipoCombustivel;
  final String? observacao;
  final double? consumo;

  Abastecimento({
    this.id,
    required this.veiculoId,
    required this.data,
    required this.quantidadeLitros,
    required this.valorPago,
    required this.quilometragem,
    required this.tipoCombustivel,
    this.observacao,
    this.consumo,
  });


  // Converte o objeto Dart para um Map (JSON) para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'veiculoId': veiculoId,
      'data': Timestamp.fromDate(data), // Converte DateTime para o formato do Firebase
      'quantidadeLitros': quantidadeLitros,
      'valorPago': valorPago,
      'quilometragem': quilometragem,
      'tipoCombustivel': tipoCombustivel,
      'observacao': observacao,
      'consumo': consumo,
    };
  }

  // Converte um Map (JSON) do Firestore para o objeto Abastecimento
  factory Abastecimento.fromMap(Map<String, dynamic> map, String id) {
    return Abastecimento(
      id: id,
      veiculoId: map['veiculoId'] ?? '',
      // Converte o formato do Firebase timestamp de volta para datetime
      data: (map['data'] as Timestamp).toDate(), 
      quantidadeLitros: (map['quantidadeLitros'] ?? 0.0).toDouble(),
      valorPago: (map['valorPago'] ?? 0.0).toDouble(),
      quilometragem: (map['quilometragem'] ?? 0.0).toDouble(),
      tipoCombustivel: map['tipoCombustivel'] ?? '',
      observacao: map['observacao'],
      consumo: (map['consumo'] ?? 0.0).toDouble(),
    );
  }
}