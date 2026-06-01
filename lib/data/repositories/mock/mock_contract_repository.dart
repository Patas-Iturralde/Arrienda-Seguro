import 'dart:async';

import '../../models/contract.dart';
import '../../models/contract_status.dart';
import '../../models/user_role.dart';
import '../contract_repository.dart';
import '../../services/mock_data_service.dart';

class MockContractRepository implements ContractRepository {
  MockContractRepository(this._data);

  final MockDataService _data;
  final _controller = StreamController<List<Contract>>.broadcast();

  List<Contract> _filter(String? userId, String? role) {
    if (role == UserRole.admin.name || userId == null) {
      return List.from(_data.contracts);
    }
    if (role == UserRole.arrendador.name) {
      return _data.contracts.where((c) => c.arrendadorId == userId).toList();
    }
    if (role == UserRole.arrendatario.name) {
      return _data.contracts.where((c) => c.arrendatarioId == userId).toList();
    }
    return List.from(_data.contracts);
  }

  void _notify(String? userId, String? role) {
    _controller.add(_filter(userId, role));
  }

  @override
  Future<List<Contract>> getContracts({String? userId, String? role}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _filter(userId, role);
  }

  @override
  Future<Contract?> getContractById(String id) async {
    return _data.contracts.cast<Contract?>().firstWhere(
          (c) => c!.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<Contract> createContract(Contract contract) async {
    _data.contracts.add(contract);
    _controller.add(List.from(_data.contracts));
    return contract;
  }

  @override
  Future<Contract> updateContract(Contract contract) async {
    final index = _data.contracts.indexWhere((c) => c.id == contract.id);
    if (index >= 0) _data.contracts[index] = contract;
    _controller.add(List.from(_data.contracts));
    return contract;
  }

  @override
  Future<Contract> renewContract(
    String contractId,
    DateTime nuevaFechaFin,
    double? nuevoCanon,
  ) async {
    final index = _data.contracts.indexWhere((c) => c.id == contractId);
    if (index < 0) throw Exception('Contrato no encontrado');

    final updated = _data.contracts[index].copyWith(
      fechaFin: nuevaFechaFin,
      canonMensual: nuevoCanon ?? _data.contracts[index].canonMensual,
      status: ContractStatus.activo,
    );
    _data.contracts[index] = updated;
    _controller.add(List.from(_data.contracts));
    return updated;
  }

  @override
  Stream<List<Contract>> watchContracts({String? userId, String? role}) {
    _notify(userId, role);
    return _controller.stream.map((_) => _filter(userId, role));
  }

  void dispose() => _controller.close();
}
