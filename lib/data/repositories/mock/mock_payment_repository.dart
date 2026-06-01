import 'dart:async';

import '../../models/app_document.dart';
import '../../models/app_notification.dart';
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
      ..sort((a, b) {
        final da = DateTime(a.anio, a.mes);
        final db = DateTime(b.anio, b.mes);
        return db.compareTo(da);
      });
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

  @override
  Future<List<Payment>> getPaymentsByContract(String contractId) async {
    return _byContract(contractId);
  }

  @override
  Future<List<Payment>> getPendingPayments({String? userId, String? role}) async {
    final ids = _contractIdsForUser(userId, role);
    return _data.payments
        .where((p) =>
            ids.contains(p.contractId) &&
            (p.status == PaymentStatus.pendiente ||
                p.status == PaymentStatus.vencido))
        .toList();
  }

  @override
  Future<Payment?> getNextPayment({String? userId, String? role}) async {
    final pending = await getPendingPayments(userId: userId, role: role);
    if (pending.isEmpty) return null;
    pending.sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
    return pending.first;
  }

  @override
  Future<Payment> registerPayment(String paymentId, {DateTime? fechaPago}) async {
    final index = _data.payments.indexWhere((p) => p.id == paymentId);
    if (index < 0) throw Exception('Pago no encontrado');

    final payment = _data.payments[index];
    final reciboId = 'doc-recibo-${payment.contractId}-${payment.mes}';
    final updated = payment.copyWith(
      status: PaymentStatus.pagado,
      fechaPago: fechaPago ?? DateTime.now(),
      reciboId: reciboId,
    );
    _data.payments[index] = updated;

    _data.documents.add(AppDocument(
      id: reciboId,
      nombre: 'Recibo ${payment.mes}/${payment.anio}',
      tipo: DocumentType.recibo,
      tamano: '0.3 MB',
      fecha: DateTime.now(),
      contractId: payment.contractId,
      paymentId: payment.id,
    ));

    _data.notifications.insert(
      0,
      AppNotification(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        titulo: 'Pago registrado',
        descripcion: 'Se registró el pago de arriendo correspondiente al periodo.',
        fecha: DateTime.now(),
        type: NotificationType.pagoRegistrado,
        group: NotificationGroup.hoy,
        contractId: payment.contractId,
      ),
    );

    _notifyContract(payment.contractId);
    return updated;
  }

  @override
  Future<Payment> createPayment(Payment payment) async {
    _data.payments.add(payment);
    _notifyContract(payment.contractId);
    return payment;
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
