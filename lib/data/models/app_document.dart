enum DocumentType {
  contrato('Contrato'),
  recibo('Recibo'),
  otro('Otro');

  const DocumentType(this.label);
  final String label;
}

class AppDocument {
  const AppDocument({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.tamano,
    required this.fecha,
    this.contractId,
    this.paymentId,
    this.url,
    this.comprobanteBase64,
  });

  final String id;
  final String nombre;
  final DocumentType tipo;
  final String tamano;
  final DateTime fecha;
  final String? contractId;
  final String? paymentId;
  final String? url;
  final String? comprobanteBase64;

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo.name,
        'tamano': tamano,
        'fecha': fecha.toIso8601String(),
        'contractId': contractId,
        'paymentId': paymentId,
        'url': url,
        'comprobanteBase64': comprobanteBase64,
      };

  factory AppDocument.fromMap(Map<String, dynamic> map) {
    return AppDocument(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      tipo: DocumentType.values.firstWhere((t) => t.name == map['tipo']),
      tamano: map['tamano'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      contractId: map['contractId'] as String?,
      paymentId: map['paymentId'] as String?,
      url: map['url'] as String?,
      comprobanteBase64: map['comprobanteBase64'] as String?,
    );
  }
}
