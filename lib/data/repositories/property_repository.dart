import '../models/property.dart';

abstract class PropertyRepository {
  Stream<List<Property>> watchAvailableProperties();
  Stream<List<Property>> watchPropertiesByLandlord(String arrendadorId);
  Future<List<Property>> getAvailableProperties();
  Future<List<Property>> getPropertiesByLandlord(String arrendadorId);
  Future<Property?> getById(String id);
  Future<Property> create(Property property);
  Future<Property> update(Property property);
  Future<void> setAvailability(String id, bool disponible);
  Future<void> delete(String id);
}
