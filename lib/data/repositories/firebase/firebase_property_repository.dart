import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/property.dart';
import '../property_repository.dart';

class FirebasePropertyRepository implements PropertyRepository {
  FirebasePropertyRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('properties');

  @override
  Stream<List<Property>> watchAvailableProperties() {
    return _collection
        .where('disponible', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(_mapSnapshot);
  }

  @override
  Stream<List<Property>> watchPropertiesByLandlord(String arrendadorId) {
    return _collection
        .where('arrendadorId', isEqualTo: arrendadorId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(_mapSnapshot);
  }

  List<Property> _mapSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => Property.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<Property>> getAvailableProperties() async {
    final snapshot = await _collection
        .where('disponible', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .get();
    return _mapSnapshot(snapshot);
  }

  @override
  Future<List<Property>> getPropertiesByLandlord(String arrendadorId) async {
    final snapshot = await _collection
        .where('arrendadorId', isEqualTo: arrendadorId)
        .orderBy('updatedAt', descending: true)
        .get();
    return _mapSnapshot(snapshot);
  }

  @override
  Future<Property?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Property.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<Property> create(Property property) async {
    final now = DateTime.now();
    final data = property.copyWith(createdAt: now, updatedAt: now).toMap();
    late final String id;
    if (property.id.isEmpty) {
      final doc = await _collection.add(data);
      id = doc.id;
    } else {
      id = property.id;
      await _collection.doc(id).set(data);
    }
    return property.copyWith(id: id, createdAt: now, updatedAt: now);
  }

  @override
  Future<Property> update(Property property) async {
    final now = DateTime.now();
    final data = property.copyWith(updatedAt: now).toMap();
    await _collection.doc(property.id).update(data);
    return property.copyWith(updatedAt: now);
  }

  @override
  Future<void> setAvailability(String id, bool disponible) async {
    await _collection.doc(id).update({
      'disponible': disponible,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }
}
