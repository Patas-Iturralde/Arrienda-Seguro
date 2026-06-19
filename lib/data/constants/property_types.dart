/// Tipos de inmueble disponibles en el formulario.
class PropertyTypes {
  PropertyTypes._();

  static const List<String> all = [
    'Departamento',
    'Casa',
    'Estudio',
    'Suite',
    'Penthouse',
    'Villa',
    'Local comercial',
    'Oficina',
    'Bodega',
    'Habitación',
    'Terreno',
    'Otro',
  ];

  static String normalize(String? value) {
    if (value == null || value.trim().isEmpty) return all.first;
    final match = all.firstWhere(
      (t) => t.toLowerCase() == value.trim().toLowerCase(),
      orElse: () => value.trim(),
    );
    return match;
  }
}
