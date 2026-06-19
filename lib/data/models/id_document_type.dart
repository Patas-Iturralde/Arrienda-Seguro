enum IdDocumentType {
  cedula('Cédula de identidad'),
  licencia('Licencia de conducción'),
  pasaporte('Pasaporte');

  const IdDocumentType(this.label);
  final String label;

  static IdDocumentType fromName(String? value) {
    return IdDocumentType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => IdDocumentType.cedula,
    );
  }
}
