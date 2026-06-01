enum ContractStatus {
  activo('Activo'),
  porVencer('Por vencer'),
  finalizado('Finalizado');

  const ContractStatus(this.label);
  final String label;
}
