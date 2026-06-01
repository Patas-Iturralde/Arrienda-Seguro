enum PaymentStatus {
  pagado('Pagado'),
  pendiente('Pendiente'),
  vencido('Vencido');

  const PaymentStatus(this.label);
  final String label;
}
