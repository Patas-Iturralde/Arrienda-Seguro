enum PaymentConcept {
  deposito('Abono inicial / Depósito'),
  canon('Canon de arriendo');

  const PaymentConcept(this.label);
  final String label;
}
