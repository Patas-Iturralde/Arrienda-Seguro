import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/contract.dart';
import '../../models/contract_status.dart';
import '../../models/user_role.dart';
import '../contract_repository.dart';

class FirebaseContractRepository implements ContractRepository {
  FirebaseContractRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('contracts');

  Contract _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Contract.fromMap({...doc.data()!, 'id': doc.id});
  }

  List<Contract> _mapSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map(_fromDoc).toList();
  }

  Future<List<Contract>> _queryByField(String field, String userId) async {
    try {
      final snapshot =
          await _collection.where(field, isEqualTo: userId).get();
      return _mapSnapshot(snapshot);
    } on FirebaseException catch (e) {
      debugPrint('Error al leer contratos ($field): ${e.code}');
      return [];
    }
  }

  Future<List<Contract>> _fetchAll() async {
    try {
      final snapshot = await _collection.get();
      return _mapSnapshot(snapshot);
    } on FirebaseException catch (e) {
      debugPrint('Error al leer todos los contratos: ${e.code}');
      return [];
    }
  }

  Future<List<Contract>> _fetchForUser(String? userId, String? role) async {
    if (role == UserRole.admin.name || userId == null) {
      return _fetchAll();
    }
    if (role == UserRole.arrendador.name) {
      return _queryByField('arrendadorId', userId);
    }
    if (role == UserRole.arrendatario.name) {
      return _queryByField('arrendatarioId', userId);
    }
    return _fetchAll();
  }

  Stream<List<Contract>> _watchByField(String field, String userId) {
    return _collection
        .where(field, isEqualTo: userId)
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Future<List<Contract>> getContracts({String? userId, String? role}) async {
    return _fetchForUser(userId, role);
  }

  @override
  Future<Contract?> getContractById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return _fromDoc(doc);
    } on FirebaseException catch (e) {
      debugPrint('Error al leer contrato $id: ${e.code}');
      return null;
    }
  }

  @override
  Future<Contract> createContract(Contract contract) async {
    await _collection.doc(contract.id).set(contract.toMap());
    return contract;
  }

  @override
  Future<Contract> updateContract(Contract contract) async {
    await _collection.doc(contract.id).update(contract.toMap());
    return contract;
  }

  @override
  Future<Contract> renewContract(
    String contractId,
    DateTime nuevaFechaFin,
    double? nuevoCanon,
  ) async {
    final current = await getContractById(contractId);
    if (current == null) throw Exception('Contrato no encontrado');

    final updated = current.copyWith(
      fechaFin: nuevaFechaFin,
      canonMensual: nuevoCanon ?? current.canonMensual,
      status: ContractStatus.activo,
    );
    await _collection.doc(contractId).update(updated.toMap());
    return updated;
  }

  @override
  Stream<List<Contract>> watchContracts({String? userId, String? role}) {
    if (role == UserRole.admin.name || userId == null) {
      return _collection.snapshots().map(_mapSnapshot);
    }
    if (role == UserRole.arrendador.name) {
      return _watchByField('arrendadorId', userId);
    }
    if (role == UserRole.arrendatario.name) {
      return _watchByField('arrendatarioId', userId);
    }
    return _collection.snapshots().map(_mapSnapshot);
  }
}
