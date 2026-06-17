import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../models/property.dart';
import '../../services/mock_data_service.dart';
import '../property_repository.dart';

class MockPropertyRepository implements PropertyRepository {
  MockPropertyRepository(this._data);

  final MockDataService _data;
  final _uuid = const Uuid();
  final _controller = StreamController<List<Property>>.broadcast();

  void _notify() => _controller.add(List.from(_data.properties));

  @override
  Stream<List<Property>> watchAvailableProperties() async* {
    yield _data.properties.where((p) => p.disponible).toList();
    yield* _controller.stream.map(
      (list) => list.where((p) => p.disponible).toList(),
    );
  }

  @override
  Stream<List<Property>> watchPropertiesByLandlord(String arrendadorId) async* {
    yield _data.properties.where((p) => p.arrendadorId == arrendadorId).toList();
    yield* _controller.stream.map(
      (list) => list.where((p) => p.arrendadorId == arrendadorId).toList(),
    );
  }

  @override
  Future<List<Property>> getAvailableProperties() async {
    return _data.properties.where((p) => p.disponible).toList();
  }

  @override
  Future<List<Property>> getPropertiesByLandlord(String arrendadorId) async {
    return _data.properties.where((p) => p.arrendadorId == arrendadorId).toList();
  }

  @override
  Future<Property?> getById(String id) async {
    return _data.properties.cast<Property?>().firstWhere(
          (p) => p!.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<Property> create(Property property) async {
    final created = property.copyWith(
      id: property.id.isEmpty ? _uuid.v4() : property.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _data.properties.add(created);
    _notify();
    return created;
  }

  @override
  Future<Property> update(Property property) async {
    final index = _data.properties.indexWhere((p) => p.id == property.id);
    if (index == -1) throw StateError('Propiedad no encontrada');
    final updated = property.copyWith(updatedAt: DateTime.now());
    _data.properties[index] = updated;
    _notify();
    return updated;
  }

  @override
  Future<void> setAvailability(String id, bool disponible) async {
    final index = _data.properties.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _data.properties[index] =
        _data.properties[index].copyWith(disponible: disponible, updatedAt: DateTime.now());
    _notify();
  }

  @override
  Future<void> delete(String id) async {
    _data.properties.removeWhere((p) => p.id == id);
    _notify();
  }
}
