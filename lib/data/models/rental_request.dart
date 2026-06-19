enum RentalRequestStatus {
  pendiente('Pendiente'),
  aceptada('Aceptada'),
  rechazada('Rechazada'),
  contratoGenerado('Contrato generado');

  const RentalRequestStatus(this.label);
  final String label;
}

class RentalRequest {
  const RentalRequest({
    required this.id,
    required this.propertyId,
    required this.propertyName,
    required this.arrendadorId,
    required this.arrendatarioId,
    required this.arrendatarioName,
    this.status = RentalRequestStatus.pendiente,
    this.mensaje,
    this.createdAt,
  });

  final String id;
  final String propertyId;
  final String propertyName;
  final String arrendadorId;
  final String arrendatarioId;
  final String arrendatarioName;
  final RentalRequestStatus status;
  final String? mensaje;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'propertyId': propertyId,
        'propertyName': propertyName,
        'arrendadorId': arrendadorId,
        'arrendatarioId': arrendatarioId,
        'arrendatarioName': arrendatarioName,
        'status': status.name,
        'mensaje': mensaje,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory RentalRequest.fromMap(String id, Map<String, dynamic> map) {
    return RentalRequest(
      id: id,
      propertyId: map['propertyId'] as String? ?? '',
      propertyName: map['propertyName'] as String? ?? '',
      arrendadorId: map['arrendadorId'] as String? ?? '',
      arrendatarioId: map['arrendatarioId'] as String? ?? '',
      arrendatarioName: map['arrendatarioName'] as String? ?? '',
      status: RentalRequestStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RentalRequestStatus.pendiente,
      ),
      mensaje: map['mensaje'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
    );
  }
}
