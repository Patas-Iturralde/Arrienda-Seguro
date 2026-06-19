import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/rental_request.dart';
import '../rental_request_repository.dart';

class FirebaseRentalRequestRepository implements RentalRequestRepository {
  FirebaseRentalRequestRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('rental_requests');

  @override
  Future<RentalRequest> create(RentalRequest request) async {
    try {
      final now = DateTime.now();
      final data = request.copyWithCreatedAt(now).toMap();
      final doc = await _collection.add(data);
      return request.copyWithId(doc.id, createdAt: now);
    } on FirebaseException catch (e) {
      debugPrint('Error al crear solicitud de arriendo: ${e.code}');
      rethrow;
    }
  }

  @override
  Future<List<RentalRequest>> getByTenant(String arrendatarioId) async {
    try {
      final snapshot = await _collection
          .where('arrendatarioId', isEqualTo: arrendatarioId)
          .get();
      return snapshot.docs
          .map((doc) => RentalRequest.fromMap(doc.id, doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      debugPrint('Error al leer solicitudes de arriendo: ${e.code}');
      return [];
    }
  }

  @override
  Future<List<RentalRequest>> getByLandlord(String arrendadorId) async {
    try {
      final snapshot = await _collection
          .where('arrendadorId', isEqualTo: arrendadorId)
          .get();
      final list = snapshot.docs
          .map((doc) => RentalRequest.fromMap(doc.id, doc.data()))
          .toList();
      list.sort((a, b) {
        final aDate = a.createdAt ?? DateTime(1970);
        final bDate = b.createdAt ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });
      return list;
    } on FirebaseException catch (e) {
      debugPrint('Error al leer solicitudes del arrendador: ${e.code}');
      return [];
    }
  }

  @override
  Future<RentalRequest> updateStatus(
    String id,
    RentalRequestStatus status,
  ) async {
    await _collection.doc(id).update({'status': status.name});
    final doc = await _collection.doc(id).get();
    return RentalRequest.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<bool> hasPendingRequest({
    required String propertyId,
    required String arrendatarioId,
  }) async {
    final list = await getByTenant(arrendatarioId);
    return list.any(
      (r) =>
          r.propertyId == propertyId &&
          r.status == RentalRequestStatus.pendiente,
    );
  }
}

extension on RentalRequest {
  RentalRequest copyWithCreatedAt(DateTime createdAt) => RentalRequest(
        id: id,
        propertyId: propertyId,
        propertyName: propertyName,
        arrendadorId: arrendadorId,
        arrendatarioId: arrendatarioId,
        arrendatarioName: arrendatarioName,
        status: status,
        mensaje: mensaje,
        createdAt: createdAt,
      );

  RentalRequest copyWithId(String newId, {DateTime? createdAt}) => RentalRequest(
        id: newId,
        propertyId: propertyId,
        propertyName: propertyName,
        arrendadorId: arrendadorId,
        arrendatarioId: arrendatarioId,
        arrendatarioName: arrendatarioName,
        status: status,
        mensaje: mensaje,
        createdAt: createdAt ?? this.createdAt,
      );
}
