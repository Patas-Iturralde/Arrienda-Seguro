import '../models/rental_request.dart';

abstract class RentalRequestRepository {
  Future<RentalRequest> create(RentalRequest request);
  Future<List<RentalRequest>> getByTenant(String arrendatarioId);
  Future<List<RentalRequest>> getByLandlord(String arrendadorId);
  Future<RentalRequest> updateStatus(String id, RentalRequestStatus status);
  Future<bool> hasPendingRequest({
    required String propertyId,
    required String arrendatarioId,
  });
}
