import '../models/app_user.dart';
import '../models/auth_result.dart';
import '../models/id_document_type.dart';
import '../models/marital_status.dart';
import '../models/user_role.dart';

/// Contrato abstracto para autenticación.
abstract class AuthRepository {
  AppUser? get currentUser;
  Stream<AppUser?> get authStateChanges;

  Future<AuthResult> signIn(String email, String password);
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String telefono,
    required String cedula,
    required UserRole role,
    required MaritalStatus estadoCivil,
    required String ocupacion,
    required String domicilio,
    required IdDocumentType tipoDocumentoIdentidad,
    required DateTime fechaNacimiento,
    required String documentoIdentidadBase64,
    String? fotoBase64,
  });
  Future<AuthResult> updateProfilePhoto(String userId, String fotoBase64);
  Future<void> signOut();
  Future<List<AppUser>> getUsersByRole(UserRole role);
  Future<AppUser?> getUserById(String id);
}
