enum ReminderType {
  pagoArriendo,
  vencimientoContrato,
}

class Reminder {
  const Reminder({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.type,
    this.contractId,
    this.contractName,
  });

  final String id;
  final String titulo;
  final DateTime fecha;
  final ReminderType type;
  final String? contractId;
  final String? contractName;

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'fecha': fecha.toIso8601String(),
        'type': type.name,
        'contractId': contractId,
        'contractName': contractName,
      };

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as String,
      titulo: map['titulo'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      type: ReminderType.values.firstWhere((t) => t.name == map['type']),
      contractId: map['contractId'] as String?,
      contractName: map['contractName'] as String?,
    );
  }
}
