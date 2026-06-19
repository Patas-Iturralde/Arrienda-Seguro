import 'id_document_type.dart';
import 'marital_status.dart';
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
    required this.estadoCivil,
    required this.ocupacion,
    required this.domicilio,
    required this.tipoDocumentoIdentidad,
    required this.fechaNacimiento,
    this.fotoBase64,
    this.documentoIdentidadBase64,
  });

  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String telefono;
  final String cedula;
  final UserRole role;
  final MaritalStatus estadoCivil;
  final String ocupacion;
  final String domicilio;
  final IdDocumentType tipoDocumentoIdentidad;
  final DateTime fechaNacimiento;

  /// Foto de perfil codificada en base64 (JPEG) para Firestore.
  final String? fotoBase64;

  /// Foto del documento de identidad (cédula, licencia o pasaporte).
  final String? documentoIdentidadBase64;

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
    MaritalStatus? estadoCivil,
    String? ocupacion,
    String? domicilio,
    IdDocumentType? tipoDocumentoIdentidad,
    DateTime? fechaNacimiento,
    String? fotoBase64,
    String? documentoIdentidadBase64,
    bool clearFotoBase64 = false,
    bool clearDocumentoIdentidadBase64 = false,
  }) {
    return AppUser(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      cedula: cedula ?? this.cedula,
      role: role ?? this.role,
      estadoCivil: estadoCivil ?? this.estadoCivil,
      ocupacion: ocupacion ?? this.ocupacion,
      domicilio: domicilio ?? this.domicilio,
      tipoDocumentoIdentidad:
          tipoDocumentoIdentidad ?? this.tipoDocumentoIdentidad,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      fotoBase64: clearFotoBase64 ? null : (fotoBase64 ?? this.fotoBase64),
      documentoIdentidadBase64: clearDocumentoIdentidadBase64
          ? null
          : (documentoIdentidadBase64 ?? this.documentoIdentidadBase64),
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
      'estadoCivil': estadoCivil.name,
      'ocupacion': ocupacion,
      'domicilio': domicilio,
      'tipoDocumentoIdentidad': tipoDocumentoIdentidad.name,
      'fechaNacimiento': fechaNacimiento.toIso8601String(),
    };
    if (fotoBase64 != null && fotoBase64!.isNotEmpty) {
      map['fotoBase64'] = fotoBase64;
    }
    if (documentoIdentidadBase64 != null &&
        documentoIdentidadBase64!.isNotEmpty) {
      map['documentoIdentidadBase64'] = documentoIdentidadBase64;
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
      estadoCivil: MaritalStatus.fromName(map['estadoCivil'] as String?),
      ocupacion: map['ocupacion'] as String? ?? '',
      domicilio: map['domicilio'] as String? ?? '',
      tipoDocumentoIdentidad:
          IdDocumentType.fromName(map['tipoDocumentoIdentidad'] as String?),
      fechaNacimiento: map['fechaNacimiento'] != null
          ? DateTime.parse(map['fechaNacimiento'] as String)
          : DateTime(1990, 1, 1),
      fotoBase64: map['fotoBase64'] as String? ?? map['fotoUrl'] as String?,
      documentoIdentidadBase64: map['documentoIdentidadBase64'] as String?,
    );
  }
}
