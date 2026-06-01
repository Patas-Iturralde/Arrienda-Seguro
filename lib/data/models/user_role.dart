enum UserRole {
  admin('Administrador'),
  arrendador('Arrendador'),
  arrendatario('Arrendatario');

  const UserRole(this.label);
  final String label;
}
