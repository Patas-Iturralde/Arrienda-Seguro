import 'payment_concept.dart';
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
    this.concepto = PaymentConcept.canon,
    this.fechaPago,
    this.reciboId,
    this.comprobanteBase64,
    this.rechazoMotivo,
  });

  final String id;
  final String contractId;
  final int mes;
  final int anio;
  final double monto;
  final DateTime fechaVencimiento;
  final PaymentStatus status;
  final PaymentConcept concepto;
  final DateTime? fechaPago;
  final String? reciboId;

  /// Captura o foto del comprobante de transferencia (base64 JPEG).
  final String? comprobanteBase64;
  final String? rechazoMotivo;

  DateTime get periodo => DateTime(anio, mes);

  bool get esDeposito => concepto == PaymentConcept.deposito;

  Map<String, dynamic> toMap() => {
        'id': id,
        'contractId': contractId,
        'mes': mes,
        'anio': anio,
        'monto': monto,
        'fechaVencimiento': fechaVencimiento.toIso8601String(),
        'status': status.name,
        'concepto': concepto.name,
        'fechaPago': fechaPago?.toIso8601String(),
        'reciboId': reciboId,
        'comprobanteBase64': comprobanteBase64,
        'rechazoMotivo': rechazoMotivo,
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
      concepto: PaymentConcept.values.firstWhere(
        (c) => c.name == map['concepto'],
        orElse: () => PaymentConcept.canon,
      ),
      fechaPago: map['fechaPago'] != null
          ? DateTime.parse(map['fechaPago'] as String)
          : null,
      reciboId: map['reciboId'] as String?,
      comprobanteBase64: map['comprobanteBase64'] as String?,
      rechazoMotivo: map['rechazoMotivo'] as String?,
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
    PaymentConcept? concepto,
    DateTime? fechaPago,
    String? reciboId,
    String? comprobanteBase64,
    String? rechazoMotivo,
    bool clearRechazoMotivo = false,
  }) {
    return Payment(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      mes: mes ?? this.mes,
      anio: anio ?? this.anio,
      monto: monto ?? this.monto,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      status: status ?? this.status,
      concepto: concepto ?? this.concepto,
      fechaPago: fechaPago ?? this.fechaPago,
      reciboId: reciboId ?? this.reciboId,
      comprobanteBase64: comprobanteBase64 ?? this.comprobanteBase64,
      rechazoMotivo:
          clearRechazoMotivo ? null : (rechazoMotivo ?? this.rechazoMotivo),
    );
  }
}
