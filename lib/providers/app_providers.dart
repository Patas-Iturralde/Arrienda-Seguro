import 'package:flutter/foundation.dart';

import '../data/models/app_user.dart';
import '../data/models/auth_result.dart';
import '../data/models/contract.dart';
import '../data/models/payment.dart';
import '../data/models/user_role.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/contract_repository.dart';
import '../data/repositories/payment_repository.dart';
import '../core/di/service_locator.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  AppUser? get currentUser => _authRepository.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<AuthResult> signIn(String email, String password) async {
    final result = await _authRepository.signIn(email, password);
    if (result.isSuccess) notifyListeners();
    return result;
  }

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
    final result = await _authRepository.signUp(
      email: email,
      password: password,
      nombre: nombre,
      apellido: apellido,
      role: role,
      telefono: telefono,
      cedula: cedula,
      fotoBase64: fotoBase64,
    );
    if (result.isSuccess) notifyListeners();
    return result;
  }

  Future<AuthResult> updateProfilePhoto(String fotoBase64) async {
    final user = currentUser;
    if (user == null) {
      return const AuthResult.failure('No hay sesión activa.');
    }
    final result =
        await _authRepository.updateProfilePhoto(user.id, fotoBase64);
    if (result.isSuccess) notifyListeners();
    return result;
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    notifyListeners();
  }
}

class ContractProvider extends ChangeNotifier {
  ContractProvider(this._repository);

  final ContractRepository _repository;

  List<Contract> _contracts = [];
  bool _loading = false;

  List<Contract> get contracts => _contracts;
  bool get loading => _loading;

  List<Contract> get activeContracts =>
      _contracts.where((c) => c.status.name != 'finalizado').toList();

  Future<void> loadContracts(AppUser? user) async {
    _loading = true;
    notifyListeners();
    _contracts = await _repository.getContracts(
      userId: user?.id,
      role: user?.role.name,
    );
    _loading = false;
    notifyListeners();
  }

  Future<Contract?> getById(String id) => _repository.getContractById(id);

  Future<Contract> createContract(Contract contract) async {
    final created = await _repository.createContract(contract);
    await loadContracts(ServiceLocator.instance.authRepository.currentUser);
    return created;
  }

  Future<Contract> renewContract(
    String id,
    DateTime nuevaFechaFin,
    double? nuevoCanon,
  ) async {
    final renewed =
        await _repository.renewContract(id, nuevaFechaFin, nuevoCanon);
    await loadContracts(ServiceLocator.instance.authRepository.currentUser);
    return renewed;
  }
}

class PaymentProvider extends ChangeNotifier {
  PaymentProvider(this._repository);

  final PaymentRepository _repository;

  List<Payment> _payments = [];
  Payment? _nextPayment;
  int _pendingCount = 0;

  List<Payment> get payments => _payments;
  Payment? get nextPayment => _nextPayment;
  int get pendingCount => _pendingCount;

  Future<void> loadDashboardData(AppUser? user) async {
    _nextPayment = await _repository.getNextPayment(
      userId: user?.id,
      role: user?.role.name,
    );
    final pending = await _repository.getPendingPayments(
      userId: user?.id,
      role: user?.role.name,
    );
    _pendingCount = pending.length;
    notifyListeners();
  }

  Future<void> loadByContract(String contractId) async {
    _payments = await _repository.getPaymentsByContract(contractId);
    notifyListeners();
  }

  Future<Payment> registerPayment(String paymentId) async {
    final payment = await _repository.registerPayment(paymentId);
    notifyListeners();
    return payment;
  }
}
