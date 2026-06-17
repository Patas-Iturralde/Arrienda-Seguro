class Property {
  const Property({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    required this.ciudad,
    required this.valor,
    required this.arrendadorId,
    this.tipo = 'Departamento',
    this.fotos = const [],
    this.servicios = const [],
    this.disponible = true,
    this.arrendadorNombre,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String nombre;
  final String descripcion;
  final String direccion;
  final String ciudad;
  final double valor;
  final String arrendadorId;
  final String tipo;

  /// Lista de fotografías en base64 (JPEG) guardadas en Firestore.
  final List<String> fotos;
  final List<String> servicios;
  final bool disponible;
  final String? arrendadorNombre;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get direccionCompleta => '$direccion, $ciudad';
  String? get fotoPrincipal => fotos.isNotEmpty ? fotos.first : null;

  Property copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    String? direccion,
    String? ciudad,
    double? valor,
    String? arrendadorId,
    String? tipo,
    List<String>? fotos,
    List<String>? servicios,
    bool? disponible,
    String? arrendadorNombre,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      valor: valor ?? this.valor,
      arrendadorId: arrendadorId ?? this.arrendadorId,
      tipo: tipo ?? this.tipo,
      fotos: fotos ?? this.fotos,
      servicios: servicios ?? this.servicios,
      disponible: disponible ?? this.disponible,
      arrendadorNombre: arrendadorNombre ?? this.arrendadorNombre,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'direccion': direccion,
        'ciudad': ciudad,
        'valor': valor,
        'arrendadorId': arrendadorId,
        'tipo': tipo,
        'fotos': fotos,
        'servicios': servicios,
        'disponible': disponible,
        'arrendadorNombre': arrendadorNombre,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    return Property(
      id: id,
      nombre: map['nombre'] as String? ?? '',
      descripcion: map['descripcion'] as String? ?? '',
      direccion: map['direccion'] as String? ?? '',
      ciudad: map['ciudad'] as String? ?? '',
      valor: (map['valor'] as num?)?.toDouble() ?? 0,
      arrendadorId: map['arrendadorId'] as String? ?? '',
      tipo: map['tipo'] as String? ?? 'Departamento',
      fotos: List<String>.from(map['fotos'] as List? ?? []),
      servicios: List<String>.from(map['servicios'] as List? ?? []),
      disponible: map['disponible'] as bool? ?? true,
      arrendadorNombre: map['arrendadorNombre'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String)
          : null,
    );
  }
}
