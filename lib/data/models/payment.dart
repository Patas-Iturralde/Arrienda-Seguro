import 'payment_status.dart';

class Payment {
  const Payment({
    required this.id,
    required this.contractId,
    required this.mes,
    required this.anio,
    required this.monto,
    required this.fechaVencimiento,
    required this.status,
    this.fechaPago,
    this.reciboId,
  });

  final String id;
  final String contractId;
  final int mes;
  final int anio;
  final double monto;
  final DateTime fechaVencimiento;
  final PaymentStatus status;
  final DateTime? fechaPago;
  final String? reciboId;

  DateTime get periodo => DateTime(anio, mes);

  Map<String, dynamic> toMap() => {
        'id': id,
        'contractId': contractId,
        'mes': mes,
        'anio': anio,
        'monto': monto,
        'fechaVencimiento': fechaVencimiento.toIso8601String(),
        'status': status.name,
        'fechaPago': fechaPago?.toIso8601String(),
        'reciboId': reciboId,
      };

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      contractId: map['contractId'] as String,
      mes: map['mes'] as int,
      anio: map['anio'] as int,
      monto: (map['monto'] as num).toDouble(),
      fechaVencimiento: DateTime.parse(map['fechaVencimiento'] as String),
      status: PaymentStatus.values.firstWhere((s) => s.name == map['status']),
      fechaPago: map['fechaPago'] != null
          ? DateTime.parse(map['fechaPago'] as String)
          : null,
      reciboId: map['reciboId'] as String?,
    );
  }

  Payment copyWith({
    String? id,
    String? contractId,
    int? mes,
    int? anio,
    double? monto,
    DateTime? fechaVencimiento,
    PaymentStatus? status,
    DateTime? fechaPago,
    String? reciboId,
  }) {
    return Payment(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      mes: mes ?? this.mes,
      anio: anio ?? this.anio,
      monto: monto ?? this.monto,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      status: status ?? this.status,
      fechaPago: fechaPago ?? this.fechaPago,
      reciboId: reciboId ?? this.reciboId,
    );
  }
}
