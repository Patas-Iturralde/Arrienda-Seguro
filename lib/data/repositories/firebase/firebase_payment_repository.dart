import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/utils/payment_schedule_generator.dart';
import '../../models/contract.dart';
import '../../models/payment.dart';
import '../../models/payment_status.dart';
import '../../models/user_role.dart';
import '../payment_repository.dart';

class FirebasePaymentRepository implements PaymentRepository {
  FirebasePaymentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('payments');

  Map<String, dynamic> _toFirestore(Payment payment, Contract contract) {
    return {
      ...payment.toMap(),
      'arrendadorId': contract.arrendadorId,
      'arrendatarioId': contract.arrendatarioId,
    };
  }

  Payment _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;
    return Payment.fromMap(data);
  }

  List<Payment> _mapSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final list = snapshot.docs.map(_fromDoc).toList();
    list.sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
    return list;
  }

  Future<List<Payment>> _queryByField(String field, String userId) async {
    try {
      final snapshot =
          await _collection.where(field, isEqualTo: userId).get();
      return _mapSnapshot(snapshot);
    } on FirebaseException catch (e) {
      debugPrint('Error al leer pagos ($field): ${e.code}');
      return [];
    }
  }

  @override
  Future<List<Payment>> getPaymentsByContract(
    String contractId, {
    String? userId,
  }) async {
    if (userId == null) {
      try {
        final snapshot =
            await _collection.where('contractId', isEqualTo: contractId).get();
        return _mapSnapshot(snapshot);
      } on FirebaseException catch (e) {
        debugPrint('Error al leer pagos del contrato: ${e.code}');
        return [];
      }
    }

    final byId = <String, Payment>{};
    for (final field in ['arrendatarioId', 'arrendadorId']) {
      try {
        final snapshot = await _collection
            .where('contractId', isEqualTo: contractId)
            .where(field, isEqualTo: userId)
            .get();
        for (final payment in _mapSnapshot(snapshot)) {
          byId[payment.id] = payment;
        }
      } on FirebaseException catch (e) {
        debugPrint('Error al leer pagos del contrato ($field): ${e.code}');
      }
    }
    final list = byId.values.toList();
    list.sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
    return list;
  }

  @override
  Future<Payment?> getPaymentById(String paymentId) async {
    try {
      final doc = await _collection.doc(paymentId).get();
      if (!doc.exists || doc.data() == null) return null;
      return _fromDoc(doc);
    } on FirebaseException catch (e) {
      debugPrint('Error al leer pago $paymentId: ${e.code}');
      return null;
    }
  }

  @override
  Future<List<Payment>> getPendingPayments({
    String? userId,
    String? role,
  }) async {
    if (userId == null) return [];

    if (role == UserRole.arrendador.name) {
      try {
        final snapshot = await _collection
            .where('arrendadorId', isEqualTo: userId)
            .where('status', isEqualTo: PaymentStatus.enRevision.name)
            .get();
        return _mapSnapshot(snapshot);
      } on FirebaseException catch (e) {
        debugPrint('Error al leer pagos en revisión: ${e.code}');
        return [];
      }
    }

    final all = await _queryByField('arrendatarioId', userId);
    return all.where((p) => p.status.puedeRegistrar).toList();
  }

  @override
  Future<List<Payment>> getPaymentsPendingApproval(String landlordId) async {
    return getPendingPayments(userId: landlordId, role: UserRole.arrendador.name);
  }

  @override
  Future<List<Payment>> getAllPaymentsForUser({
    required String userId,
    required String role,
  }) async {
    if (role == UserRole.arrendador.name) {
      return _queryByField('arrendadorId', userId);
    }
    if (role == UserRole.arrendatario.name) {
      return _queryByField('arrendatarioId', userId);
    }
    try {
      final snapshot = await _collection.get();
      return _mapSnapshot(snapshot);
    } on FirebaseException catch (e) {
      debugPrint('Error al leer pagos: ${e.code}');
      return [];
    }
  }

  @override
  Future<Payment?> getNextPayment({String? userId, String? role}) async {
    final pending = await getPendingPayments(userId: userId, role: role);
    if (pending.isEmpty) return null;
    pending.sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
    return pending.first;
  }

  @override
  Future<Payment> submitPayment(
    String paymentId, {
    required String comprobanteBase64,
  }) async {
    final payment = await getPaymentById(paymentId);
    if (payment == null) throw Exception('Pago no encontrado');
    if (!payment.status.puedeRegistrar) {
      throw Exception('Este pago no puede registrarse en su estado actual');
    }

    final updated = payment.copyWith(
      status: PaymentStatus.enRevision,
      comprobanteBase64: comprobanteBase64,
      clearRechazoMotivo: true,
    );
    await _collection.doc(paymentId).update(updated.toMap());
    return updated;
  }

  @override
  Future<Payment> approvePayment(String paymentId) async {
    final payment = await getPaymentById(paymentId);
    if (payment == null) throw Exception('Pago no encontrado');
    if (payment.status != PaymentStatus.enRevision) {
      throw Exception('Solo se pueden aprobar pagos en revisión');
    }

    final reciboId =
        'doc-recibo-${payment.contractId}-${payment.concepto.name}-${payment.mes}-${payment.anio}';
    final updated = payment.copyWith(
      status: PaymentStatus.pagado,
      fechaPago: DateTime.now(),
      reciboId: reciboId,
      clearRechazoMotivo: true,
    );
    await _collection.doc(paymentId).update(updated.toMap());
    return updated;
  }

  @override
  Future<Payment> rejectPayment(String paymentId, {String? motivo}) async {
    final payment = await getPaymentById(paymentId);
    if (payment == null) throw Exception('Pago no encontrado');
    if (payment.status != PaymentStatus.enRevision) {
      throw Exception('Solo se pueden rechazar pagos en revisión');
    }

    final updated = payment.copyWith(
      status: PaymentStatus.rechazado,
      rechazoMotivo: motivo?.trim().isNotEmpty == true ? motivo!.trim() : null,
    );
    await _collection.doc(paymentId).update(updated.toMap());
    return updated;
  }

  @override
  Future<Payment> createPayment(Payment payment) async {
    throw UnsupportedError(
      'Use generateScheduleForContract para crear pagos en Firebase.',
    );
  }

  @override
  Future<List<Payment>> generateScheduleForContract(Contract contract) async {
    final existing = await getPaymentsByContract(
      contract.id,
      userId: contract.arrendadorId,
    );
    if (existing.isNotEmpty) return existing;

    final schedule = PaymentScheduleGenerator.forContract(contract);
    final batch = _firestore.batch();
    for (final payment in schedule) {
      final ref = _collection.doc(payment.id);
      batch.set(ref, _toFirestore(payment, contract));
    }
    await batch.commit();
    return schedule;
  }

  @override
  Stream<List<Payment>> watchPaymentsByContract(String contractId) {
    return _collection
        .where('contractId', isEqualTo: contractId)
        .snapshots()
        .map(_mapSnapshot);
  }
}
