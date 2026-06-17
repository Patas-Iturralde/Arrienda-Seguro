import 'dart:async';

import '../../models/app_user.dart';
import '../../models/auth_result.dart';
import '../../models/user_role.dart';
import '../auth_repository.dart';
import '../../services/mock_data_service.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._data);

  final MockDataService _data;
  AppUser? _currentUser;
  final _controller = StreamController<AppUser?>.broadcast();

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  Future<AuthResult> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final user = _data.users.cast<AppUser?>().firstWhere(
          (u) => u!.email.toLowerCase() == email.toLowerCase(),
          orElse: () => null,
        );
    if (user != null) {
      _currentUser = user;
      _controller.add(user);
      return AuthResult.success(user);
    }
    return const AuthResult.failure('Credenciales inválidas. Intenta de nuevo.');
  }

  @override
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required String telefono,
    required String cedula,
    required UserRole role,
    String? fotoBase64,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final exists = _data.users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (exists) {
      return const AuthResult.failure('Ya existe una cuenta con ese correo.');
    }
    final user = AppUser(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      nombre: nombre,
      apellido: apellido,
      email: email,
      telefono: telefono,
      cedula: cedula,
      role: role,
      fotoBase64: fotoBase64,
    );
    _data.users.add(user);
    _currentUser = user;
    _controller.add(user);
    return AuthResult.success(user);
  }

  @override
  Future<AuthResult> updateProfilePhoto(String userId, String fotoBase64) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _data.users.indexWhere((u) => u.id == userId);
    if (index == -1) {
      return const AuthResult.failure('Usuario no encontrado.');
    }
    final updated = _data.users[index].copyWith(fotoBase64: fotoBase64);
    _data.users[index] = updated;
    if (_currentUser?.id == userId) {
      _currentUser = updated;
      _controller.add(updated);
    }
    return AuthResult.success(updated);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<List<AppUser>> getUsersByRole(UserRole role) async {
    return _data.users.where((u) => u.role == role).toList();
  }

  @override
  Future<AppUser?> getUserById(String id) async {
    return _data.users.cast<AppUser?>().firstWhere(
          (u) => u!.id == id,
          orElse: () => null,
        );
  }

  void dispose() => _controller.close();
}
