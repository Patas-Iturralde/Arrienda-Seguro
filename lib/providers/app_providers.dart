import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/app_user.dart';
import '../data/models/auth_result.dart';
import '../data/models/contract.dart';
import '../data/models/contract_status.dart';
import '../data/models/payment.dart';
import '../data/models/user_role.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/contract_repository.dart';
import '../data/repositories/payment_repository.dart';
import '../core/di/service_locator.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository) {
    _subscription = _authRepository.authStateChanges.listen((_) {
      _ready = true;
      notifyListeners();
    });
  }

  final AuthRepository _authRepository;
  StreamSubscription<AppUser?>? _subscription;
  bool _ready = false;

  AppUser? get currentUser => _authRepository.currentUser;
  bool get isAuthenticated => currentUser != null;
  bool get isReady => _ready;

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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class ContractProvider extends ChangeNotifier {
  ContractProvider(this._repository, this._paymentRepository);

  final ContractRepository _repository;
  final PaymentRepository _paymentRepository;

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
    await _ensurePaymentsForContracts(user);
    _loading = false;
    notifyListeners();
  }

  Future<void> _ensurePaymentsForContracts(AppUser? user) async {
    for (final contract in _contracts) {
      if (contract.status == ContractStatus.finalizado) continue;
      final existing = await _paymentRepository.getPaymentsByContract(
        contract.id,
        userId: user?.id ?? contract.arrendadorId,
      );
      if (existing.isEmpty) {
        await _paymentRepository.generateScheduleForContract(contract);
      }
    }
  }

  Future<Contract?> getById(String id) => _repository.getContractById(id);

  Future<Contract> createContract(Contract contract) async {
    final created = await _repository.createContract(contract);
    await _paymentRepository.generateScheduleForContract(created);
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
  List<Payment> _approvals = [];
  Payment? _nextPayment;
  int _pendingCount = 0;

  List<Payment> get payments => _payments;
  List<Payment> get approvals => _approvals;
  Payment? get nextPayment => _nextPayment;
  int get pendingCount => _pendingCount;

  Future<void> loadDashboardData(AppUser? user) async {
    if (user == null) return;

    if (user.role == UserRole.arrendador) {
      _approvals =
          await _repository.getPaymentsPendingApproval(user.id);
      _pendingCount = _approvals.length;
      _nextPayment = _approvals.isNotEmpty ? _approvals.first : null;
    } else {
      _approvals = [];
      _nextPayment = await _repository.getNextPayment(
        userId: user.id,
        role: user.role.name,
      );
      final pending = await _repository.getPendingPayments(
        userId: user.id,
        role: user.role.name,
      );
      _pendingCount = pending.length;
    }
    notifyListeners();
  }

  Future<void> loadByContract(String contractId, {AppUser? user}) async {
    _payments = await _repository.getPaymentsByContract(
      contractId,
      userId: user?.id,
    );
    notifyListeners();
  }

  Future<List<Payment>> loadAllForUser(AppUser user) async {
    final list = await _repository.getAllPaymentsForUser(
      userId: user.id,
      role: user.role.name,
    );
    _payments = list;
    notifyListeners();
    return list;
  }

  Future<Payment?> getPaymentById(String paymentId) =>
      _repository.getPaymentById(paymentId);

  Future<Payment> submitPayment(
    String paymentId, {
    required String comprobanteBase64,
  }) async {
    final payment = await _repository.submitPayment(
      paymentId,
      comprobanteBase64: comprobanteBase64,
    );
    notifyListeners();
    return payment;
  }

  Future<Payment> approvePayment(String paymentId) async {
    final payment = await _repository.approvePayment(paymentId);
    notifyListeners();
    return payment;
  }

  Future<Payment> rejectPayment(String paymentId, {String? motivo}) async {
    final payment = await _repository.rejectPayment(paymentId, motivo: motivo);
    notifyListeners();
    return payment;
  }
}
