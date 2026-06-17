import 'app_user.dart';

class AuthResult {
  const AuthResult.success(this.user) : error = null;
  const AuthResult.failure(this.error) : user = null;

  final AppUser? user;
  final String? error;

  bool get isSuccess => user != null;
}
