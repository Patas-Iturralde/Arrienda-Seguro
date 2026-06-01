enum NotificationType {
  pagoRegistrado,
  pagoProximo,
  contratoPorVencer,
  contratoRenovado,
  recordatorio,
}

enum NotificationGroup {
  hoy,
  proximos,
  anteriores,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.type,
    required this.group,
    this.contractId,
    this.leida = false,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final NotificationType type;
  final NotificationGroup group;
  final String? contractId;
  final bool leida;

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha': fecha.toIso8601String(),
        'type': type.name,
        'group': group.name,
        'contractId': contractId,
        'leida': leida,
      };

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      type: NotificationType.values.firstWhere((t) => t.name == map['type']),
      group: NotificationGroup.values.firstWhere((g) => g.name == map['group']),
      contractId: map['contractId'] as String?,
      leida: map['leida'] as bool? ?? false,
    );
  }
}
