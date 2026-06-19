/// Datos precargados al generar un contrato desde una solicitud aceptada.
class ContractGenerationArgs {
  const ContractGenerationArgs({
    required this.rentalRequestId,
    required this.propertyId,
    required this.propertyName,
    required this.propertyTipo,
    required this.direccion,
    required this.ciudad,
    required this.canonMensual,
    required this.arrendadorId,
    required this.arrendadorNombre,
    required this.arrendadorApellido,
    required this.arrendadorCedula,
    required this.arrendadorEmail,
    required this.arrendatarioId,
    required this.arrendatarioNombre,
    required this.arrendatarioApellido,
    required this.arrendatarioCedula,
    required this.arrendatarioEmail,
  });

  final String rentalRequestId;
  final String propertyId;
  final String propertyName;
  final String propertyTipo;
  final String direccion;
  final String ciudad;
  final double canonMensual;
  final String arrendadorId;
  final String arrendadorNombre;
  final String arrendadorApellido;
  final String arrendadorCedula;
  final String arrendadorEmail;
  final String arrendatarioId;
  final String arrendatarioNombre;
  final String arrendatarioApellido;
  final String arrendatarioCedula;
  final String arrendatarioEmail;
}
