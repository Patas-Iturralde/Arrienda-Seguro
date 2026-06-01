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
    this.fotoUrl,
  });

  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String cedula;
  final UserRole role;
  final String? fotoUrl;

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
    String? fotoUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      cedula: cedula ?? this.cedula,
      role: role ?? this.role,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'telefono': telefono,
        'cedula': cedula,
        'role': role.name,
        'fotoUrl': fotoUrl,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      apellido: map['apellido'] as String,
      email: map['email'] as String,
      telefono: map['telefono'] as String,
      cedula: map['cedula'] as String,
      role: UserRole.values.firstWhere((r) => r.name == map['role']),
      fotoUrl: map['fotoUrl'] as String?,
    );
  }
}
