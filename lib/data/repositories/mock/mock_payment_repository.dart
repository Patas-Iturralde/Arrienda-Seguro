import 'dart:async';

import '../../../core/utils/payment_schedule_generator.dart';
import '../../models/app_document.dart';
import '../../models/app_notification.dart';
import '../../models/contract.dart';
import '../../models/payment.dart';
import '../../models/payment_status.dart';
import '../../models/user_role.dart';
import '../payment_repository.dart';
import '../../services/mock_data_service.dart';

class MockPaymentRepository implements PaymentRepository {
  MockPaymentRepository(this._data);

  final MockDataService _data;
  final _controllers = <String, StreamController<List<Payment>>>{};

  List<Payment> _byContract(String contractId) {
    return _data.payments.where((p) => p.contractId == contractId).toList()
      ..sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
  }

  List<String> _contractIdsForUser(String? userId, String? role) {
    if (role == UserRole.admin.name || userId == null) {
      return _data.contracts.map((c) => c.id).toList();
    }
    if (role == UserRole.arrendador.name) {
      return _data.contracts
          .where((c) => c.arrendadorId == userId)
          .map((c) => c.id)
          .toList();
    }
    return _data.contracts
        .where((c) => c.arrendatarioId == userId)
        .map((c) => c.id)
        .toList();
  }

  void _updatePayment(int index, Payment payment) {
    _data.payments[index] = payment;
    _notifyContract(payment.contractId);
  }

  @override
  Future<List<Payment>> getPaymentsByContract(String contractId) async {
    return _byContract(contractId);
  }

  @override
  Future<Payment?> getPaymentById(String paymentId) async {
    try {
      return _data.payments.firstWhere((p) => p.id == paymentId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Payment>> getPendingPayments({String? userId, String? role}) async {
    final ids = _contractIdsForUser(userId, role);
    if (role == UserRole.arrendador.name) {
      return _data.payments
          .where(
            (p) =>
                ids.contains(p.contractId) &&
                p.status == PaymentStatus.enRevision,
          )
          .toList();
    }
    return _data.payments
        .where(
          (p) => ids.contains(p.contractId) && p.status.puedeRegistrar,
        )
        .toList();
  }

  @override
  Future<List<Payment>> getPaymentsPendingApproval(String landlordId) async {
    final ids = _contractIdsForUser(landlordId, UserRole.arrendador.name);
    return _data.payments
        .where(
          (p) =>
              ids.contains(p.contractId) &&
              p.status == PaymentStatus.enRevision,
        )
        .toList()
      ..sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
  }

  @override
  Future<List<Payment>> getAllPaymentsForUser({
    required String userId,
    required String role,
  }) async {
    final ids = _contractIdsForUser(userId, role);
    return _data.payments
        .where((p) => ids.contains(p.contractId))
        .toList()
      ..sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
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
    final index = _data.payments.indexWhere((p) => p.id == paymentId);
    if (index < 0) throw Exception('Pago no encontrado');

    final payment = _data.payments[index];
    if (!payment.status.puedeRegistrar) {
      throw Exception('Este pago no puede registrarse en su estado actual');
    }

    final updated = payment.copyWith(
      status: PaymentStatus.enRevision,
      comprobanteBase64: comprobanteBase64,
      clearRechazoMotivo: true,
    );
    _updatePayment(index, updated);

    _data.notifications.insert(
      0,
      AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        titulo: 'Pago enviado a revisión',
        descripcion:
            'El arrendatario envió un comprobante. Revisa y aprueba el pago.',
        fecha: DateTime.now(),
        type: NotificationType.pagoRegistrado,
        group: NotificationGroup.hoy,
        contractId: payment.contractId,
      ),
    );

    return updated;
  }

  @override
  Future<Payment> approvePayment(String paymentId) async {
    final index = _data.payments.indexWhere((p) => p.id == paymentId);
    if (index < 0) throw Exception('Pago no encontrado');

    final payment = _data.payments[index];
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
    _updatePayment(index, updated);

    _data.documents.add(AppDocument(
      id: reciboId,
      nombre: payment.esDeposito
          ? 'Recibo abono inicial'
          : 'Recibo ${payment.mes}/${payment.anio}',
      tipo: DocumentType.recibo,
      tamano: 'Comprobante adjunto',
      fecha: DateTime.now(),
      contractId: payment.contractId,
      paymentId: payment.id,
      comprobanteBase64: payment.comprobanteBase64,
    ));

    _data.notifications.insert(
      0,
      AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        titulo: 'Pago aprobado',
        descripcion: 'El arrendador aprobó tu comprobante de pago.',
        fecha: DateTime.now(),
        type: NotificationType.pagoRegistrado,
        group: NotificationGroup.hoy,
        contractId: payment.contractId,
      ),
    );

    return updated;
  }

  @override
  Future<Payment> rejectPayment(String paymentId, {String? motivo}) async {
    final index = _data.payments.indexWhere((p) => p.id == paymentId);
    if (index < 0) throw Exception('Pago no encontrado');

    final payment = _data.payments[index];
    if (payment.status != PaymentStatus.enRevision) {
      throw Exception('Solo se pueden rechazar pagos en revisión');
    }

    final updated = payment.copyWith(
      status: PaymentStatus.rechazado,
      rechazoMotivo: motivo?.trim().isNotEmpty == true ? motivo!.trim() : null,
    );
    _updatePayment(index, updated);

    _data.notifications.insert(
      0,
      AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        titulo: 'Pago rechazado',
        descripcion: motivo?.isNotEmpty == true
            ? motivo!
            : 'El arrendador rechazó tu comprobante. Puedes enviar uno nuevo.',
        fecha: DateTime.now(),
        type: NotificationType.pagoRegistrado,
        group: NotificationGroup.hoy,
        contractId: payment.contractId,
      ),
    );

    return updated;
  }

  @override
  Future<Payment> createPayment(Payment payment) async {
    _data.payments.add(payment);
    _notifyContract(payment.contractId);
    return payment;
  }

  @override
  Future<List<Payment>> generateScheduleForContract(Contract contract) async {
    final existing = _byContract(contract.id);
    if (existing.isNotEmpty) return existing;

    final schedule = PaymentScheduleGenerator.forContract(contract);
    _data.payments.addAll(schedule);
    _notifyContract(contract.id);
    return schedule;
  }

  @override
  Stream<List<Payment>> watchPaymentsByContract(String contractId) {
    _controllers.putIfAbsent(contractId, StreamController.broadcast);
    _notifyContract(contractId);
    return _controllers[contractId]!.stream;
  }

  void _notifyContract(String contractId) {
    final controller = _controllers[contractId];
    if (controller != null && !controller.isClosed) {
      controller.add(_byContract(contractId));
    }
  }

  void dispose() {
    for (final c in _controllers.values) {
      c.close();
    }
  }
}
