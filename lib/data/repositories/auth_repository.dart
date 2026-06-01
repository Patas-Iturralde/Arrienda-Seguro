import '../models/app_user.dart';
import '../models/user_role.dart';

/// Contrato abstracto para autenticación.
/// Implementar con FirebaseAuthRepository cuando se conecte Firebase.
abstract class AuthRepository {
  AppUser? get currentUser;
  Stream<AppUser?> get authStateChanges;

  Future<AppUser?> signIn(String email, String password);
  Future<void> signOut();
  Future<List<AppUser>> getUsersByRole(UserRole role);
  Future<AppUser?> getUserById(String id);
}
