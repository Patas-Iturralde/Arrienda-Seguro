class Property {
  const Property({
    required this.id,
    required this.tipo,
    required this.direccion,
    required this.ciudad,
    required this.nombre,
  });

  final String id;
  final String tipo;
  final String direccion;
  final String ciudad;
  final String nombre;

  String get direccionCompleta => '$direccion, $ciudad';

  Map<String, dynamic> toMap() => {
        'id': id,
        'tipo': tipo,
        'direccion': direccion,
        'ciudad': ciudad,
        'nombre': nombre,
      };

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'] as String,
      tipo: map['tipo'] as String,
      direccion: map['direccion'] as String,
      ciudad: map['ciudad'] as String,
      nombre: map['nombre'] as String,
    );
  }
}
