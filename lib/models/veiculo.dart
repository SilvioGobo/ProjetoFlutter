class Veiculo {
  // Id do doc no firestore
  final String? id; 
  
  final String modelo;
  final String marca;
  final String placa;
  final String ano;
  final String tipoCombustivel; // Ex: Gasolina, Etanol, Diesel

  Veiculo({
    this.id,
    required this.modelo,
    required this.marca,
    required this.placa,
    required this.ano,
    required this.tipoCombustivel,
  });

  //conversao para o firestore
  //pega o veiculo e passa para json (reconhecido pelo firestore)
  Map<String, dynamic> toMap() {
    return {
      'modelo': modelo,
      'marca': marca,
      'placa': placa,
      'ano': ano,
      'tipoCombustivel': tipoCombustivel,
    };
  }

  //conversao para o app ler
  //pega o veiculo de json para objeto no app
  factory Veiculo.fromMap(Map<String, dynamic> map, String id) {
    return Veiculo(
      id: id,
      modelo: map['modelo'] ?? '',
      marca: map['marca'] ?? '',
      placa: map['placa'] ?? '',
      ano: map['ano'] ?? '',
      tipoCombustivel: map['tipoCombustivel'] ?? '',
    );
  }
}