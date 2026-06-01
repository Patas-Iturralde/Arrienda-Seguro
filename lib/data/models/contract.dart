import 'contract_status.dart';

class ContractClause {
  const ContractClause({
    required this.titulo,
    required this.contenido,
  });

  final String titulo;
  final String contenido;

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'contenido': contenido,
      };

  factory ContractClause.fromMap(Map<String, dynamic> map) {
    return ContractClause(
      titulo: map['titulo'] as String,
      contenido: map['contenido'] as String,
    );
  }
}

class Contract {
  const Contract({
    required this.id,
    required this.propertyId,
    required this.arrendadorId,
    required this.arrendatarioId,
    required this.propertyName,
    required this.arrendadorName,
    required this.arrendatarioName,
    required this.direccion,
    required this.canonMensual,
    required this.deposito,
    required this.fechaInicio,
    required this.fechaFin,
    required this.status,
    required this.clausulas,
    this.diaPago = 5,
  });

  final String id;
  final String propertyId;
  final String arrendadorId;
  final String arrendatarioId;
  final String propertyName;
  final String arrendadorName;
  final String arrendatarioName;
  final String direccion;
  final double canonMensual;
  final double deposito;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final ContractStatus status;
  final List<ContractClause> clausulas;
  final int diaPago;

  int get diasRestantes => fechaFin.difference(DateTime.now()).inDays;

  DateTime get proximoPago {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, diaPago);
    if (next.isBefore(now)) {
      next = DateTime(now.year, now.month + 1, diaPago);
    }
    return next;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'propertyId': propertyId,
        'arrendadorId': arrendadorId,
        'arrendatarioId': arrendatarioId,
        'propertyName': propertyName,
        'arrendadorName': arrendadorName,
        'arrendatarioName': arrendatarioName,
        'direccion': direccion,
        'canonMensual': canonMensual,
        'deposito': deposito,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'status': status.name,
        'clausulas': clausulas.map((c) => c.toMap()).toList(),
        'diaPago': diaPago,
      };

  factory Contract.fromMap(Map<String, dynamic> map) {
    return Contract(
      id: map['id'] as String,
      propertyId: map['propertyId'] as String,
      arrendadorId: map['arrendadorId'] as String,
      arrendatarioId: map['arrendatarioId'] as String,
      propertyName: map['propertyName'] as String,
      arrendadorName: map['arrendadorName'] as String,
      arrendatarioName: map['arrendatarioName'] as String,
      direccion: map['direccion'] as String,
      canonMensual: (map['canonMensual'] as num).toDouble(),
      deposito: (map['deposito'] as num).toDouble(),
      fechaInicio: DateTime.parse(map['fechaInicio'] as String),
      fechaFin: DateTime.parse(map['fechaFin'] as String),
      status: ContractStatus.values.firstWhere((s) => s.name == map['status']),
      clausulas: (map['clausulas'] as List)
          .map((c) => ContractClause.fromMap(c as Map<String, dynamic>))
          .toList(),
      diaPago: map['diaPago'] as int? ?? 5,
    );
  }

  Contract copyWith({
    String? id,
    String? propertyId,
    String? arrendadorId,
    String? arrendatarioId,
    String? propertyName,
    String? arrendadorName,
    String? arrendatarioName,
    String? direccion,
    double? canonMensual,
    double? deposito,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    ContractStatus? status,
    List<ContractClause>? clausulas,
    int? diaPago,
  }) {
    return Contract(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      arrendadorId: arrendadorId ?? this.arrendadorId,
      arrendatarioId: arrendatarioId ?? this.arrendatarioId,
      propertyName: propertyName ?? this.propertyName,
      arrendadorName: arrendadorName ?? this.arrendadorName,
      arrendatarioName: arrendatarioName ?? this.arrendatarioName,
      direccion: direccion ?? this.direccion,
      canonMensual: canonMensual ?? this.canonMensual,
      deposito: deposito ?? this.deposito,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      status: status ?? this.status,
      clausulas: clausulas ?? this.clausulas,
      diaPago: diaPago ?? this.diaPago,
    );
  }
}
