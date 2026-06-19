enum MaritalStatus {
  soltero('Soltero/a'),
  casado('Casado/a'),
  unionLibre('Unión libre'),
  divorciado('Divorciado/a'),
  viudo('Viudo/a');

  const MaritalStatus(this.label);
  final String label;

  static MaritalStatus fromName(String? value) {
    return MaritalStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => MaritalStatus.soltero,
    );
  }
}
