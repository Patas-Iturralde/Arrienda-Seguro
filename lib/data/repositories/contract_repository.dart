import '../models/contract.dart';

/// Contrato abstracto para contratos.
/// Implementar con FirebaseContractRepository cuando se conecte Firebase.
abstract class ContractRepository {
  Future<List<Contract>> getContracts({String? userId, String? role});
  Future<Contract?> getContractById(String id);
  Future<Contract> createContract(Contract contract);
  Future<Contract> updateContract(Contract contract);
  Future<Contract> renewContract(String contractId, DateTime nuevaFechaFin, double? nuevoCanon);
  Stream<List<Contract>> watchContracts({String? userId, String? role});
}
