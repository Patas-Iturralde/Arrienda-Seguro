/// Provincias y ciudades de Ecuador para selección en formularios.
class EcuadorLocations {
  EcuadorLocations._();

  static const Map<String, List<String>> provinciasCiudades = {
    'Azuay': ['Cuenca', 'Gualaceo', 'Paute', 'Sígsig'],
    'Bolívar': ['Guaranda', 'San Miguel', 'Chillanes'],
    'Cañar': ['Azogues', 'La Troncal', 'Biblián'],
    'Carchi': ['Tulcán', 'Mira', 'El Ángel'],
    'Chimborazo': ['Riobamba', 'Alausí', 'Guano'],
    'Cotopaxi': ['Latacunga', 'La Maná', 'Pujilí', 'Salcedo'],
    'El Oro': ['Machala', 'Pasaje', 'Santa Rosa', 'Huaquillas'],
    'Esmeraldas': ['Esmeraldas', 'Atacames', 'Quinindé', 'Muisne'],
    'Galápagos': ['Puerto Baquerizo Moreno', 'Puerto Ayora', 'Puerto Villamil'],
    'Guayas': ['Guayaquil', 'Durán', 'Milagro', 'Daule', 'Samborondón', 'Nobol'],
    'Imbabura': ['Ibarra', 'Otavalo', 'Atuntaqui', 'Cotacachi'],
    'Loja': ['Loja', 'Catamayo', 'Macará', 'Cariamanga'],
    'Los Ríos': ['Babahoyo', 'Quevedo', 'Ventanas', 'Vinces'],
    'Manabí': ['Portoviejo', 'Manta', 'Chone', 'Jipijapa', 'Bahía de Caráquez'],
    'Morona Santiago': ['Macas', 'Gualaquiza', 'Sucúa'],
    'Napo': ['Tena', 'Archidona', 'El Chaco'],
    'Orellana': ['Francisco de Orellana (El Coca)', 'La Joya de los Sachas'],
    'Pastaza': ['Puyo', 'Mera', 'Shell'],
    'Pichincha': ['Quito', 'Cayambe', 'Mejía', 'Rumiñahui', 'Sangolquí', 'Tabacundo'],
    'Santa Elena': ['Santa Elena', 'La Libertad', 'Salinas'],
    'Santo Domingo de los Tsáchilas': ['Santo Domingo'],
    'Sucumbíos': ['Nueva Loja (Lago Agrio)', 'Shushufindi', 'Cascales'],
    'Tungurahua': ['Ambato', 'Baños', 'Pelileo', 'Píllaro'],
    'Zamora Chinchipe': ['Zamora', 'Yantzaza', 'Zumba'],
  };

  static List<String> get provincias =>
      provinciasCiudades.keys.toList()..sort();

  static List<String> ciudadesDe(String provincia) =>
      List<String>.from(provinciasCiudades[provincia] ?? []);

  static String? findProvinciaByCiudad(String ciudad) {
    final normalized = ciudad.trim().toLowerCase();
    for (final entry in provinciasCiudades.entries) {
      final match = entry.value.any(
        (c) => c.toLowerCase() == normalized,
      );
      if (match) return entry.key;
    }
    return null;
  }

  static String? resolveProvincia({
    String? provincia,
    String? ciudad,
  }) {
    if (provincia != null && provincia.trim().isNotEmpty) {
      return provincias.contains(provincia) ? provincia : null;
    }
    if (ciudad != null && ciudad.trim().isNotEmpty) {
      return findProvinciaByCiudad(ciudad);
    }
    return null;
  }

  static String? resolveCiudad({
    required String? provincia,
    required String? ciudad,
  }) {
    if (provincia == null || ciudad == null) return ciudad;
    final cities = ciudadesDe(provincia);
    if (cities.isEmpty) return ciudad;
    final match = cities.firstWhere(
      (c) => c.toLowerCase() == ciudad.trim().toLowerCase(),
      orElse: () => ciudad,
    );
    return match;
  }
}
