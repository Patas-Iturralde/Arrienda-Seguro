import 'package:flutter/foundation.dart';

import '../data/models/app_user.dart';
import '../data/models/property.dart';
import '../data/repositories/property_repository.dart';

class PropertyProvider extends ChangeNotifier {
  PropertyProvider(this._repository);

  final PropertyRepository _repository;

  List<Property> _properties = [];
  bool _loading = false;
  String? _error;

  List<Property> get properties => _properties;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadAvailable() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _properties = await _repository.getAvailableProperties();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadByLandlord(String arrendadorId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _properties = await _repository.getPropertiesByLandlord(arrendadorId);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void watchAvailable() {
    _repository.watchAvailableProperties().listen(
      (list) {
        _properties = list;
        notifyListeners();
      },
      onError: (Object e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void watchByLandlord(String arrendadorId) {
    _repository.watchPropertiesByLandlord(arrendadorId).listen(
      (list) {
        _properties = list;
        notifyListeners();
      },
      onError: (Object e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<Property?> getById(String id) => _repository.getById(id);

  Future<Property> save(Property property, {required bool isNew}) async {
    final saved = isNew
        ? await _repository.create(property)
        : await _repository.update(property);
    notifyListeners();
    return saved;
  }

  Future<void> toggleAvailability(String id, bool disponible) async {
    await _repository.setAvailability(id, disponible);
    notifyListeners();
  }

  Future<void> deleteProperty(String id) async {
    await _repository.delete(id);
    notifyListeners();
  }

  Future<void> refresh(AppUser? user, {required bool isLandlord}) async {
    if (user == null) return;
    if (isLandlord) {
      await loadByLandlord(user.id);
    } else {
      await loadAvailable();
    }
  }
}
