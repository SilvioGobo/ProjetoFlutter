import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  // Exige usuario estar logado
  FirestoreService({required this.uid});

  // Ex: caminho padrão para cada user
  CollectionReference<Veiculo> get _veiculosCollection {
    return _db
        .collection('users')
        .doc(uid)
        .collection('veiculos')
        .withConverter<Veiculo>(
          // Converte o Map do Firestore para o objeto Veiculo
          fromFirestore: (snapshots, _) =>
              Veiculo.fromMap(snapshots.data()!, snapshots.id),
          // Converte o objeto Veiculo para o Map do Firestore
          toFirestore: (veiculo, _) => veiculo.toMap(),
        );
  }

  //CRUD VEICULO

  //read
  Stream<List<Veiculo>> getVeiculosStream() {
    // pega as mudanças em tempo real
    return _veiculosCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  //create
  Future<void> addVeiculo(Veiculo veiculo) async {
    await _veiculosCollection.add(veiculo);
  }

  //delete
  Future<void> deleteVeiculo(String veiculoId) async {
    await _veiculosCollection.doc(veiculoId).delete();
  }

  //CRUD Abastecimentos
  CollectionReference<Abastecimento> get _abastecimentosCollection {
    return _db
        .collection('users')
        .doc(uid)
        .collection('abastecimentos')
        .withConverter<Abastecimento>(
          // Converte o Map do Firestore para o objeto Abastecimento
          fromFirestore: (snapshots, _) =>
              Abastecimento.fromMap(snapshots.data()!, snapshots.id),
          // Converte o objeto Abastecimento para o Map do Firestore
          toFirestore: (abastecimento, _) => abastecimento.toMap(),
        );
  }

  // Read
  Stream<List<Abastecimento>> getAbastecimentosStream() {
    //Mais novo para o mais antigo
    final query = _abastecimentosCollection.orderBy('data', descending: true);

    //ve as mudanças em tempo real
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  //create
  Future<void> addAbastecimento(Abastecimento abastecimento) async {
    await _abastecimentosCollection.add(abastecimento);
  }

  //delete
  Future<void> deleteAbastecimento(String abastecimentoId) async {
    await _abastecimentosCollection.doc(abastecimentoId).delete();
  }

  //Calculo de consumo médio do veiculo
  //km/litro

  // Busca o último abastecimento de um veículo (o com a maior KM)
  Future<Abastecimento?> getUltimoAbastecimento(String veiculoId) async {
    final query = _abastecimentosCollection
        .where('veiculoId', isEqualTo: veiculoId)
        // Ordena pela KM, da maior para a menor
        .orderBy('quilometragem', descending: true)
        // Pega o mais recente
        .limit(1);

    final snapshot = await query.get();
    // Se encontra retorna o obj
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }
}
