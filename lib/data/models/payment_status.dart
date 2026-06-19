enum PaymentStatus {
  pendiente('Por pagar'),
  vencido('Vencido'),
  enRevision('Pendiente de aprobación'),
  pagado('Aprobado'),
  rechazado('Rechazado');

  const PaymentStatus(this.label);
  final String label;

  bool get puedeRegistrar =>
      this == PaymentStatus.pendiente ||
      this == PaymentStatus.vencido ||
      this == PaymentStatus.rechazado;

  bool get esperandoAprobacion => this == PaymentStatus.enRevision;

  bool get estaAprobado => this == PaymentStatus.pagado;
}
