import '../models/app_user.dart';
import '../models/auth_result.dart';
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
    required UserRole role,
    String telefono,
    String cedula,
  });
  Future<void> signOut();
  Future<List<AppUser>> getUsersByRole(UserRole role);
  Future<AppUser?> getUserById(String id);
}
