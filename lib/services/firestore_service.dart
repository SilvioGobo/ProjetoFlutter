import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/veiculo.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  // Exige usuario estar logado
  FirestoreService({required this.uid});

  // Ex: caminho padrão para cada user
  CollectionReference<Veiculo> get _veiculosCollection {
    return _db.collection('users').doc(uid).collection('veiculos')
      .withConverter<Veiculo>(
        // Converte o Map do Firestore para o objeto Veiculo
        fromFirestore: (snapshots, _) => Veiculo.fromMap(snapshots.data()!, snapshots.id),
        // Converte o objeto Veiculo para o Map do Firestore
        toFirestore: (veiculo, _) => veiculo.toMap(),
      );
  }

  //CRUD

  //read
  Stream<List<Veiculo>> getVeiculosStream() {
    // .snapshots() ouve todas as mudanças em tempo real
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
}