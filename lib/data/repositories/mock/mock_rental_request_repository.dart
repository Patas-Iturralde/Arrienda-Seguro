import 'package:uuid/uuid.dart';

import '../../models/rental_request.dart';
import '../../services/mock_data_service.dart';
import '../rental_request_repository.dart';

class MockRentalRequestRepository implements RentalRequestRepository {
  MockRentalRequestRepository(this._data);

  final MockDataService _data;
  final _uuid = const Uuid();

  @override
  Future<RentalRequest> create(RentalRequest request) async {
    final created = RentalRequest(
      id: _uuid.v4(),
      propertyId: request.propertyId,
      propertyName: request.propertyName,
      arrendadorId: request.arrendadorId,
      arrendatarioId: request.arrendatarioId,
      arrendatarioName: request.arrendatarioName,
      status: request.status,
      mensaje: request.mensaje,
      createdAt: DateTime.now(),
    );
    _data.rentalRequests.add(created);
    return created;
  }

  @override
  Future<List<RentalRequest>> getByTenant(String arrendatarioId) async {
    return _data.rentalRequests
        .where((r) => r.arrendatarioId == arrendatarioId)
        .toList();
  }

  @override
  Future<List<RentalRequest>> getByLandlord(String arrendadorId) async {
    final list = _data.rentalRequests
        .where((r) => r.arrendadorId == arrendadorId)
        .toList();
    list.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(1970);
      final bDate = b.createdAt ?? DateTime(1970);
      return bDate.compareTo(aDate);
    });
    return list;
  }

  @override
  Future<RentalRequest> updateStatus(
    String id,
    RentalRequestStatus status,
  ) async {
    final index = _data.rentalRequests.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw StateError('Solicitud no encontrada');
    }
    final current = _data.rentalRequests[index];
    final updated = RentalRequest(
      id: current.id,
      propertyId: current.propertyId,
      propertyName: current.propertyName,
      arrendadorId: current.arrendadorId,
      arrendatarioId: current.arrendatarioId,
      arrendatarioName: current.arrendatarioName,
      status: status,
      mensaje: current.mensaje,
      createdAt: current.createdAt,
    );
    _data.rentalRequests[index] = updated;
    return updated;
  }

  @override
  Future<bool> hasPendingRequest({
    required String propertyId,
    required String arrendatarioId,
  }) async {
    return _data.rentalRequests.any(
      (r) =>
          r.propertyId == propertyId &&
          r.arrendatarioId == arrendatarioId &&
          r.status == RentalRequestStatus.pendiente,
    );
  }
}
