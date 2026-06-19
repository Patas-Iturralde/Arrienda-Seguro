import 'package:uuid/uuid.dart';

import '../../data/models/contract.dart';
import '../../data/models/payment.dart';
import '../../data/models/payment_concept.dart';
import '../../data/models/payment_status.dart';

/// Genera abono inicial y calendario de pagos mensuales de un contrato.
class PaymentScheduleGenerator {
  PaymentScheduleGenerator._();

  static const _uuid = Uuid();

  static List<Payment> forContract(Contract contract) {
    final payments = <Payment>[];
    final now = DateTime.now();

    if (contract.deposito > 0) {
      payments.add(
        Payment(
          id: _uuid.v4(),
          contractId: contract.id,
          concepto: PaymentConcept.deposito,
          mes: contract.fechaInicio.month,
          anio: contract.fechaInicio.year,
          monto: contract.deposito,
          fechaVencimiento: DateTime(
            contract.fechaInicio.year,
            contract.fechaInicio.month,
            contract.fechaInicio.day,
          ),
          status: _statusForDueDate(contract.fechaInicio, now),
        ),
      );
    }

    final start = DateTime(contract.fechaInicio.year, contract.fechaInicio.month);
    final end = DateTime(contract.fechaFin.year, contract.fechaFin.month);

    var cursor = start;
    while (!cursor.isAfter(end)) {
      var dueDate = _canonDueDate(cursor.year, cursor.month, contract.diaPago);

      if (dueDate.isBefore(
        DateTime(
          contract.fechaInicio.year,
          contract.fechaInicio.month,
          contract.fechaInicio.day,
        ),
      )) {
        cursor = DateTime(cursor.year, cursor.month + 1);
        continue;
      }

      payments.add(
        Payment(
          id: _uuid.v4(),
          contractId: contract.id,
          concepto: PaymentConcept.canon,
          mes: cursor.month,
          anio: cursor.year,
          monto: contract.canonMensual,
          fechaVencimiento: dueDate,
          status: _statusForDueDate(dueDate, now),
        ),
      );

      cursor = DateTime(cursor.year, cursor.month + 1);
    }

    payments.sort((a, b) => a.fechaVencimiento.compareTo(b.fechaVencimiento));
    return payments;
  }

  static DateTime _canonDueDate(int year, int month, int diaPago) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = diaPago.clamp(1, lastDay);
    return DateTime(year, month, day);
  }

  static PaymentStatus _statusForDueDate(DateTime dueDate, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (due.isBefore(today)) return PaymentStatus.vencido;
    return PaymentStatus.pendiente;
  }
}
