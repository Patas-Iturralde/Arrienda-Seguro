import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.telefono,
    required this.cedula,
    required this.role,
    this.fotoBase64,
  });

  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String cedula;
  final UserRole role;

  /// Foto de perfil codificada en base64 (JPEG) para Firestore.
  final String? fotoBase64;

  String get nombreCompleto => '$nombre $apellido';
  String get iniciales =>
      '${nombre.isNotEmpty ? nombre[0] : ''}${apellido.isNotEmpty ? apellido[0] : ''}'
          .toUpperCase();

  AppUser copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? cedula,
    UserRole? role,
    String? fotoBase64,
    bool clearFotoBase64 = false,
  }) {
    return AppUser(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      cedula: cedula ?? this.cedula,
      role: role ?? this.role,
      fotoBase64: clearFotoBase64 ? null : (fotoBase64 ?? this.fotoBase64),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'cedula': cedula,
      'role': role.name,
    };
    if (fotoBase64 != null && fotoBase64!.isNotEmpty) {
      map['fotoBase64'] = fotoBase64;
    }
    return map;
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      nombre: map['nombre'] as String? ?? '',
      apellido: map['apellido'] as String? ?? '',
      email: map['email'] as String? ?? '',
      telefono: map['telefono'] as String? ?? '',
      cedula: map['cedula'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.arrendatario,
      ),
      fotoBase64: map['fotoBase64'] as String? ?? map['fotoUrl'] as String?,
    );
  }
}
