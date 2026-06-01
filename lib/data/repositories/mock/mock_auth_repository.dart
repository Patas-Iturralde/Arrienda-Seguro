import 'dart:async';

import '../../models/app_user.dart';
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
  Future<AppUser?> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final user = _data.users.cast<AppUser?>().firstWhere(
          (u) => u!.email.toLowerCase() == email.toLowerCase(),
          orElse: () => null,
        );
    if (user != null) {
      _currentUser = user;
      _controller.add(user);
    }
    return user;
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
